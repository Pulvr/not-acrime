extends CharacterBody3D

@export var speed = 10
@export var fall_acceleration = 70
@export var jump_impulse = 10

var target_velocity = Vector3.ZERO

func _physics_process(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	# 1. Handle Horizontal Movement
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		target_velocity.x = direction.x * speed
		target_velocity.z = direction.z * speed
	else:
		target_velocity.x = move_toward(target_velocity.x, 0, speed)
		target_velocity.z = move_toward(target_velocity.z, 0, speed)

	# 2. Handle Gravity
	if not is_on_floor(): 
		target_velocity.y -= fall_acceleration * delta
	else:
		# Stop accumulating gravity when grounded
		target_velocity.y = 0

	# 3. Handle Jumping
	# We check this separately so it overrides the "grounded" 0 velocity
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse

	# 4. Moving the Character
	velocity = target_velocity
	move_and_slide()
