extends CharacterBody3D

@export var SPEED = 5
@export var JUMP_VELOCITY = 4.5

@export var mouse_sensitivity = 0.002
@export var can_move = true
@export var debug_mode = false

@export var footstep_sounds: Array[AudioStream] = []

var target_velocity = Vector3.ZERO
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum PLAYER_MODES {
	WALK
}
var current_mode := PLAYER_MODES.WALK

@onready var head = $Head
@onready var interaction_ray = $Head/InteractionRay
var min_camera_x = deg_to_rad(-90)
var max_camera_x = deg_to_rad(90)

@onready var hand_mesh = $UILayer/SubViewportContainer/SubViewport/HandSlot/HandMesh
var selected_index: int = 0
var inventory: Array[ItemData]=[]
var current_item: ItemData 

@onready var footstep_player = $FootstepPlayer
@onready var footstep_timer = $FootstepPlayer/FootstepTimer

func _ready():
	# Captures the mouse and hides it
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
	
	var horizontal_velocity = Vector2(velocity.x, velocity.z)
	
	if is_on_floor() and horizontal_velocity.length() > 0.1:
		if footstep_timer.is_stopped():
			play_footstep_sound()
			footstep_timer.start()
	else:
		if not footstep_timer.is_stopped():
			footstep_timer.stop()

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
		print("Picked up: ", item_node)
		item_node.queue_free()

func change_selected_item(direction: int):
	if inventory.is_empty():
		return
		
	# Cycle through inventory index safely
	selected_index = (selected_index + direction) % inventory.size()
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
		# Just change the visual shape of the existing hand node
		hand_mesh.mesh = current_item.item_mesh
		hand_mesh.visible = true
	else:
		# Hide it if the slot is empty or has no mesh
		hand_mesh.visible = false
	

func play_footstep_sound():
	if footstep_sounds.is_empty():
		return
	
	var random_index = randi() % footstep_sounds.size()
	var chosen_sound = footstep_sounds[random_index]
	footstep_player.stream = chosen_sound
	footstep_player.pitch_scale = randf_range(0.95, 1.05)
	footstep_player.play()


func _on_footstep_timer_timeout() -> void:
	play_footstep_sound()
