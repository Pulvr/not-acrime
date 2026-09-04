extends CanvasLayer

const INVENTORY_SLOT_SCENE: PackedScene = preload(
	"res://scenes/player/inventory_ui/inventory_slot.tscn"
)

var selected_index: int = 0
var item_in_hand: ItemData

@onready var player: Node = owner
@onready var hand_mesh: MeshInstance3D = $ItemInHandContainer/ItemInHand/HandSlot/HandMesh
@onready var slot_container: VBoxContainer = $InventoryBar/SlotContainer


func _ready():
	if GlobalSettings.last_scene == GlobalSettings.LastScenes.SETTINGS_MENU:
		toggle_pause()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if event.is_action_pressed("next_item"):
		change_selected_item(1)
	elif event.is_action_pressed("prev_item"):
		change_selected_item(-1)
	if event.is_action_pressed("ui_cancel") and player.get_state() == Player.State.FREE:
		toggle_pause()


func change_selected_item(direction: int):
	if player.inventory.is_empty():
		return

	selected_index = (selected_index + direction) % player.inventory.size() 
	if selected_index < 0:
		selected_index = player.inventory.size() - 1

	update_hand_display()


func update_hand_display():
	item_in_hand = player.inventory[selected_index]
	Dialogic.VAR.set_variable("item_strings.item_in_hand", item_in_hand.name)

	if item_in_hand and item_in_hand.item_mesh:
		hand_mesh.mesh = item_in_hand.item_mesh  # Just change the visual shape of the existing hand node
		hand_mesh.visible = true
	else:
		hand_mesh.visible = false  # Hide it if the slot is empty or has no mesh

	update_inventory_ui()


func update_inventory_ui():
	for child in slot_container.get_children():
		child.queue_free()

	for i in range(player.inventory.size()):
		var slot_instance: Node = INVENTORY_SLOT_SCENE.instantiate()
		slot_container.add_child(slot_instance)

		var is_active = i == selected_index

		slot_instance.display_item(player.inventory[i], is_active)


func toggle_pause():
	player.set_state(Player.State.PAUSED)
	var new_pause_state: bool = !get_tree().paused
	get_tree().paused = new_pause_state

	$"../../PauseLayer/PauseMenu".visible = new_pause_state

	if new_pause_state:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_inventory_picked_up_item() -> void:
	item_in_hand = player.inventory[-1]
	change_selected_item(1)
	update_hand_display()
	update_inventory_ui()
