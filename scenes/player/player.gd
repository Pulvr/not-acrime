class_name Player
extends CharacterBody3D

signal player_moved
signal player_stopped

enum MovementModes { WALK, NOCLIP }
enum State { FREE, IN_DIALOGUE, IN_MINIGAME, PAUSED }

@export var debug_mode: bool = false
@export var speed: float = 5.0
@export var noclip_speed := 12.0

var mouse_sensitivity: float = GlobalSettings.mouse_sensitivity
var min_camera_x: float = deg_to_rad(-90)
var max_camera_x: float = deg_to_rad(90)

var current_mode := MovementModes.WALK
var current_state := State.FREE

var _original_layer: int
var _original_mask: int

@onready var head: Node3D = $Head
@onready var intro_target: Node3D = $"../LevelAssets/RedCell/Cellmate"
@onready var collision_shape: CollisionShape3D = $Collider

func _ready() -> void:
	_original_layer = collision_layer
	_original_mask = collision_mask

func _input(event):
	if event is InputEventMouseMotion and current_state == State.FREE:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, min_camera_x, max_camera_x)

	if event.is_action_pressed("interact"):
		check_interaction()


func _physics_process(_delta):
	_sync_debug_mode()

	match current_mode:
		MovementModes.WALK:
			walk_process(_delta)
		MovementModes.NOCLIP:
			noclip_process(_delta)

func _sync_debug_mode() -> void:
	var wanted_mode := (
		MovementModes.NOCLIP if DebugController.no_clip else MovementModes.WALK
	)
	if wanted_mode != current_mode:
		set_mode(wanted_mode)

func set_mode(new_mode: MovementModes) -> void:
	current_mode = new_mode
	velocity = Vector3.ZERO

	var is_noclip := new_mode == MovementModes.NOCLIP
	collision_layer = 0 if is_noclip else _original_layer
	collision_mask = 0 if is_noclip else _original_mask


func auto_start_intro_dialog():
	var cellmate: Node3D = intro_target

	if cellmate != null:
		head.look_at_target_with_offset(cellmate)
		if Dialogic.current_timeline == null:
			Dialogic.start("welcome_timeline")


func walk_process(_delta):
	match current_state:
		State.FREE:
			var input_dir: Vector2 = Input.get_vector(
				"move_left", "move_right", "move_forward", "move_back"
			)
			var direction: Vector3 = (
				(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			)
			if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)
			move_and_slide()

			if Vector2(velocity.x, velocity.z).length() > 0.1:  #horizontal velocity
				player_moved.emit()
			else:
				player_stopped.emit()

func noclip_process(delta: float) -> void:
	if current_state != State.FREE:
		return

	var input_dir: Vector2 = Input.get_vector(
		"move_left", "move_right", "move_forward", "move_back"
	)
	var direction: Vector3 = transform.basis * Vector3(input_dir.x, 0, input_dir.y)

	global_position += direction.normalized() * noclip_speed * delta


func check_interaction():
	if $Head/InteractionRay.is_colliding():
		var collider: Object = $Head/InteractionRay.get_collider()

		if collider.is_in_group("item_for_pickup"):
			$Inventory.pick_up_item(collider)

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


func set_state(new_state: State) -> void:
	current_state = new_state


func get_state() -> State:
	return current_state


func _on_minigame_started():
	current_state = State.IN_MINIGAME


func _on_toilet_mini_game_ended():
	current_state = State.FREE
	Dialogic.VAR.set_variable("has_sharp", true)
	$Inventory.item_added_with_dialog(
		load("res://resources/assets/items_for_pickup/sharp_metal_object/metal_object.tres")
	)


func _on_pillow_mini_game_ended():
	current_state = State.FREE
	Dialogic.VAR.set_variable("has_key", true)
	$Inventory.item_added_with_dialog(
		load("res://resources/assets/items_for_pickup/rusty_key/rusty_key.tres")
	)
