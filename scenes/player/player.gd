class_name Player
extends CharacterBody3D

signal player_moved
signal player_stopped

enum MovementModes { WALK }
enum State { FREE, IN_DIALOGUE, IN_MINIGAME, PAUSED }

@export var debug_mode: bool = false
@export var speed: float = 5.0

var mouse_sensitivity: float = GlobalSettings.mouse_sensitivity
var min_camera_x: float = deg_to_rad(-90)
var max_camera_x: float = deg_to_rad(90)

var current_mode := MovementModes.WALK
var current_state := State.FREE

@onready var inventory: Array[ItemData] = $Inventory.get_inventory()
@onready var head: Node3D = $Head
@onready var intro_target: Node3D = $"../LevelAssets/CellWithAssets/Cellmate"


func _ready():
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

	await get_tree().process_frame
	if GlobalSettings.last_scene != GlobalSettings.LastScenes.SETTINGS_MENU:
		auto_start_intro_dialog()


func _input(event):
	if event is InputEventMouseMotion and current_state == State.FREE:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, min_camera_x, max_camera_x)

	if event.is_action_pressed("interact"):
		check_interaction()


func _physics_process(_delta):
	match current_mode:
		MovementModes.WALK:
			walk_process(_delta)


func auto_start_intro_dialog():
	var cellmate: Node3D = intro_target

	if cellmate != null:
		$Head.look_at_target_with_offset(cellmate, min_camera_x, max_camera_x)
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


func _on_timeline_started():
	current_state = State.IN_DIALOGUE


func _on_timeline_ended():
	if !current_state == State.IN_MINIGAME:
		current_state = State.FREE
