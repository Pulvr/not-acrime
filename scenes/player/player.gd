extends CharacterBody3D

@export var speed = 10
@export var fall_acceleration = 55
@export var jump_impulse = 11
@export var mouse_sensitivity = 0.002
@export var can_move = true
@export var debug_mode = false

var target_velocity = Vector3.ZERO

# Reference the "Head" node to rotate it vertically
@onready var head = $Head
@onready var interaction_ray = $Head/InteractionRay

var inventory: Array[ItemData]=[]

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
		# Rotate the whole player left/right (Y axis)
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Rotate only the head up/down (X axis)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		
		# Clamp the vertical rotation so you can't flip upside down
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	if event.is_action_pressed("interact"):
		check_interaction()

	if event.is_action_pressed("show_inventory"):
		for i in inventory:
			print(i)
			print("Item :"+i.name+"\nDescription: "+i.description)
	

func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# transform.basis allows "forward" to be wherever the player is facing
	var direction_vector = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Handle Horizontal Movement
	if direction_vector and can_move:
		target_velocity.x = direction_vector.x * speed
		target_velocity.z = direction_vector.z * speed
	else:
		target_velocity.x = move_toward(target_velocity.x, 0, speed)
		target_velocity.z = move_toward(target_velocity.z, 0, speed)

	# Handle Gravity
	if not is_on_floor():
		target_velocity.y -= fall_acceleration * delta
	else:
		target_velocity.y = 0

	# Handle Jumping
	if is_on_floor() and Input.is_action_just_pressed("jump") and can_move:
		target_velocity.y = jump_impulse
	
	# Unlock mouse with ESC (useful for testing)
	if Input.is_action_just_pressed("ui_cancel") and debug_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	velocity = target_velocity
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
		print("Picked up: ", item_node)
		item_node.queue_free()
	