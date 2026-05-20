extends CharacterBody3D

@export var SPEED = 5
@export var JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var can_move = true

@export var mouse_sensitivity = 0.002
@export var debug_mode = false


#Possible different Walk Modes
enum PLAYER_MODES {
	WALK
}
var current_mode := PLAYER_MODES.WALK

#Head Rotation
@onready var head = $Head
@onready var interaction_ray = $Head/InteractionRay
@onready var hand_mesh = $UILayer/ItemInHandContainer/ItemInHand/HandSlot/HandMesh
var min_camera_x = deg_to_rad(-90)
var max_camera_x = deg_to_rad(90)

#Inventory
var selected_index: int = 0
var inventory: Array[ItemData]=[]
var current_item: ItemData 
const INVENTORY_SLOT_SCENE = preload("res://scenes/player/InventoryUI/InventorySlot.tscn")
@onready var slot_container = $UILayer/InventoryBar/SlotContainer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Captures the mouse and hides it
	
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func _on_timeline_started():
	can_move = false

func _on_timeline_ended():
	can_move = true

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, min_camera_x, max_camera_x)
	
	if event.is_action_pressed("interact"):
		check_interaction()

	if event.is_action_pressed("show_inventory"):
		for i in inventory:
			print(i)
			print("Item :"+i.name+"\nDescription: "+i.description)

	if event.is_action_pressed("next_item"):
		change_selected_item(1)
	elif event.is_action_pressed("prev_item"):
		change_selected_item(-1)
	

func _physics_process(delta):
	match current_mode:
		PLAYER_MODES.WALK:
			walk_process(delta)

func walk_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func check_interaction():
	if interaction_ray.is_colliding():
		var collider = interaction_ray.get_collider()

		if collider.is_in_group("item_for_pickup"):
			pick_up_item(collider)
		
		if collider.has_method("interact"):
			collider.interact()

func pick_up_item(item_node):
	if "data" in item_node:
		inventory.append(item_node.data)
		current_item = inventory[-1]
		change_selected_item(1)
		if debug_mode:
			print("Picked up: ", item_node)

		item_node.queue_free()

func change_selected_item(direction: int):
	if inventory.is_empty():
		return
		
	selected_index = (selected_index + direction) % inventory.size() # Cycle through inventory index safely
	if selected_index < 0:
		selected_index = inventory.size() - 1

	update_hand_display()

	if debug_mode:
		print(inventory[selected_index].name)


func update_hand_display():
	current_item = inventory[selected_index]
	if debug_mode:
		print(current_item.item_mesh)
	
	if current_item and current_item.item_mesh:
		hand_mesh.mesh = current_item.item_mesh #Just change the visual shape of the existing hand node
		hand_mesh.visible = true
	else:
		hand_mesh.visible = false #Hide it if the slot is empty or has no mesh

	update_inventory_ui()

func update_inventory_ui():
	for child in slot_container.get_children():
		child.queue_free()

	for i in range(inventory.size()):
		var slot_instance = INVENTORY_SLOT_SCENE.instantiate()
		slot_container.add_child(slot_instance)
		
		var is_active = (i == selected_index)
		
		slot_instance.display_item(inventory[i], is_active)
