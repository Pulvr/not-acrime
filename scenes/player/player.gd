class_name Player
extends CharacterBody3D

#Possible different Walk Modes
enum MovementModes { WALK }
enum State { FREE, IN_DIALOGUE, IN_MINIGAME, PAUSED }

const INVENTORY_SLOT_SCENE: PackedScene = preload(
	"res://scenes/player/inventory_ui/inventory_slot.tscn"
)

@export var debug_mode: bool = false
@export var speed: float = 5.0
@export var footstep_sounds: Array[AudioStream] = []

var mouse_sensitivity: float = GlobalSettings.mouse_sensitivity
var min_camera_x: float = deg_to_rad(-90)
var max_camera_x: float = deg_to_rad(90)

var current_mode := MovementModes.WALK
var current_state := State.FREE

#Inventory
var selected_index: int = 0
var inventory: Array[ItemData] = []
var item_in_hand: ItemData

#Player Visibility Stuff, Moving Head around, showing Items and UI Hints
@onready var head: Node3D = $Head
@onready var interaction_ray: RayCast3D = $Head/InteractionRay
@onready var hand_mesh: MeshInstance3D = $UILayer/ItemInHandContainer/ItemInHand/HandSlot/HandMesh
@onready var slot_container: VBoxContainer = $UILayer/InventoryBar/SlotContainer

@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer
@onready var footstep_timer: Timer = $FootstepPlayer/FootstepTimer

@onready var pause_menu = $"../PauseLayer/PauseMenu"
@onready var intro_target: Node3D = $"../LevelAssets/CellWithAssets/Cellmate"


func _ready():
	if GlobalSettings.last_scene == GlobalSettings.LastScenes.SETTINGS_MENU:
		toggle_pause()
		load_player_state()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

	await get_tree().process_frame
	if GlobalSettings.last_scene != GlobalSettings.LastScenes.SETTINGS_MENU:
		auto_start_intro_dialog()


# DialogController? hat ja eigentlich nichts im "player" zu suchen der Dialog
func _on_timeline_started():
	current_state = State.IN_DIALOGUE


# DialogController? hat ja eigentlich nichts im "player" zu suchen der Dialog
func _on_timeline_ended():
	if !current_state == State.IN_MINIGAME:
		current_state = State.FREE


func _input(event):
	if event is InputEventMouseMotion and current_state == State.FREE:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, min_camera_x, max_camera_x)

	if event.is_action_pressed("interact"):
		check_interaction()

	if event.is_action_pressed("show_inventory") and debug_mode:
		for item in inventory:
			print(item)
			print("Item :" + item.name + "\nDescription: " + item.description)

	if event.is_action_pressed("next_item"):
		change_selected_item(1)
	elif event.is_action_pressed("prev_item"):
		change_selected_item(-1)

	if (
		event.is_action_pressed("ui_cancel")
		and Dialogic.current_timeline == null
		and !current_state == State.IN_MINIGAME
	):
		save_player_state()
		toggle_pause()

	if event.is_action_pressed("ui_cancel") and current_state == State.FREE:
		toggle_pause()


func _physics_process(_delta):
	match current_mode:
		MovementModes.WALK:
			walk_process(_delta)


# Autostart, vielleicht auch ein Dialog Controller?
func auto_start_intro_dialog():
	var cellmate: Node3D = intro_target

	if cellmate != null:
		$Head.look_at_target_with_offset(cellmate, min_camera_x, max_camera_x)
		if Dialogic.current_timeline == null:
			Dialogic.start("welcome_timeline")


func walk_process(_delta):
	match current_state:
		State.FREE:
			var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
			var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)

			move_and_slide()

			var horizontal_velocity: Vector2 = Vector2(velocity.x, velocity.z)

			if is_on_floor() and horizontal_velocity.length() > 0.1:
				if footstep_timer.is_stopped():
					play_footstep_sound()
					footstep_timer.start()
			else:
				if not footstep_timer.is_stopped():
					footstep_timer.stop()


func check_interaction():
	if interaction_ray.is_colliding():
		var collider: Object = interaction_ray.get_collider()

		if collider.is_in_group("item_for_pickup"):
			pick_up_item(collider)

		elif collider.has_method("start_dialog"):
			collider.start_dialog()

		elif collider and collider.has_method("interact"):
			if collider.has_signal("toilet_minigame_started"):
				if not collider.toilet_minigame_started.is_connected(_on_minigame_started):
					collider.toilet_minigame_started.connect(_on_minigame_started)
					collider.toilet_minigame_ended.connect(_on_toilet_mini_game_ended)

			if collider.has_signal("pillow_minigame_started"):
				if not collider.pillow_minigame_started.is_connected(_on_minigame_started):
					collider.pillow_minigame_started.connect(_on_minigame_started)
					collider.pillow_minigame_ended.connect(_on_pillow_mini_game_ended)
			collider.interact()


# Inventory?
func pick_up_item(item_node):
	if "data" in item_node:
		add_item_to_inventory(item_node.data)
		if debug_mode:
			print("Picked up: ", item_node)
		item_node.queue_free()


# UI
func change_selected_item(direction: int):
	if inventory.is_empty():
		return

	selected_index = (selected_index + direction) % inventory.size()  # Cycle through inventory index safely
	if selected_index < 0:
		selected_index = inventory.size() - 1

	update_hand_display()


# Inventory?
func add_item_to_inventory(item_data: ItemData):
	inventory.append(item_data)
	item_in_hand = inventory[-1]
	change_selected_item(1)
	update_inventory_ui()


# UI
func update_hand_display():
	item_in_hand = inventory[selected_index]
	Dialogic.VAR.set_variable("item_strings.item_in_hand", item_in_hand.name)
	if debug_mode:
		print(Dialogic.VAR.get("item_strings").get("item_in_hand"))

	if item_in_hand and item_in_hand.item_mesh:
		hand_mesh.mesh = item_in_hand.item_mesh  # Just change the visual shape of the existing hand node
		hand_mesh.visible = true
	else:
		hand_mesh.visible = false  # Hide it if the slot is empty or has no mesh

	update_inventory_ui()


# Sound
func play_footstep_sound():
	if footstep_sounds.is_empty():
		return

	var random_index = randi() % footstep_sounds.size()
	var chosen_sound = footstep_sounds[random_index]
	footstep_player.stream = chosen_sound
	footstep_player.pitch_scale = randf_range(0.95, 1.05)
	footstep_player.play()


# Pause Controller?
func toggle_pause():
	current_state = State.PAUSED
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state

	pause_menu.visible = new_pause_state

	if new_pause_state:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if has_node("FootstepTimer"):
			$FootstepTimer.stop()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# UI
func update_inventory_ui():
	for child in slot_container.get_children():
		child.queue_free()

	for i in range(inventory.size()):
		var slot_instance = INVENTORY_SLOT_SCENE.instantiate()
		slot_container.add_child(slot_instance)

		var is_active = i == selected_index

		slot_instance.display_item(inventory[i], is_active)


# Inventory
func item_added_with_dialog(item: ItemData):
	Dialogic.VAR.set_variable("item_strings.item_received", item.name)
	Dialogic.VAR.set_variable("item_strings.item_description", item.description)
	add_item_to_inventory(item)
	if Dialogic.current_timeline == null:
		Dialogic.start("item_received_timeline")


# PlayerController
func save_player_state():
	GlobalSettings.last_player_position = global_position
	GlobalSettings.last_player_rotation = rotation
	GlobalSettings.last_head_rotation = head.rotation
	GlobalSettings.last_inventory = inventory.duplicate()
	GlobalSettings.last_selected_index = selected_index


# PlayerController
func load_player_state():
	global_position = GlobalSettings.last_player_position
	rotation = GlobalSettings.last_player_rotation
	head.rotation = GlobalSettings.last_head_rotation
	inventory = GlobalSettings.last_inventory.duplicate()
	selected_index = GlobalSettings.last_selected_index
	if not inventory.is_empty():
		update_hand_display()
	else:
		update_inventory_ui()


func set_state(new_state: State) -> void:
	current_state = new_state


func get_state() -> State:
	return current_state


func _on_minigame_started():
	current_state = State.IN_MINIGAME


func _on_toilet_mini_game_ended():
	current_state = State.FREE
	Dialogic.VAR.set_variable("has_sharp", true)
	item_added_with_dialog(
		load("res://resources/assets/items_for_pickup/sharp_metal_object/metal_object.tres")
	)


func _on_pillow_mini_game_ended():
	current_state = State.FREE
	Dialogic.VAR.set_variable("has_key", true)
	item_added_with_dialog(load("res://resources/assets/items_for_pickup/rusty_key/rusty_key.tres"))


# SoundController
func _on_footstep_timer_timeout() -> void:
	play_footstep_sound()


# Inventory
func remove_item(_item_name):
	pass
	#for item in inventory:
	#	if item.name == item_name:
