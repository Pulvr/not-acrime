class_name DrawerMinigameStarter
extends StaticBody3D

@export var drawer_animation_name: String = ""
@export var minigame_scene: PackedScene

@export_group("Settings Camera focus point")
@export var target_mesh: CollisionShape3D
@export var x_distance: float = 1.5
@export var fine_tune_y: float = -0.01
@export var fine_tune_z: float = 0.0
@export var move_duration: float = 1.5

var is_open: bool = false
var is_solved: bool = false
var is_focused: bool = false
var is_animation_running: bool = false

var original_position: Vector3
var original_rotation: Quaternion
var animation_tween: Tween
var _active_minigame: Node = null

@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var player = get_tree().get_first_node_in_group("player")
@onready var player_head = player.head


func interact() -> void:
	if is_animation_running:
		return

	if is_solved:
		_toggle_drawer_animation()
		return

	if is_focused:
		_unfocus_camera()
	else:
		_focus_camera_and_start()


func _focus_camera_and_start() -> void:
	original_position = player_head.global_position
	original_rotation = player_head.global_transform.basis.get_rotation_quaternion()

	var target_node: Node3D = target_mesh if target_mesh else self
	var origin = target_node.global_position
	var basis = target_node.global_transform.basis

	var target_pos = (
		origin + (basis.x * x_distance) + (basis.y * fine_tune_y) + (basis.z * fine_tune_z)
	)

	var temp_transform = Transform3D()
	temp_transform.origin = target_pos
	temp_transform = temp_transform.looking_at(origin, Vector3.UP)

	var target_rot = temp_transform.basis.get_rotation_quaternion()

	player.set_state(Player.State.IN_MINIGAME)
	is_focused = true
	_animate_head(target_pos, target_rot, move_duration, false)


func _unfocus_camera() -> void:
	is_focused = false
	_animate_head(original_position, original_rotation, move_duration, true)


func _animate_head(
	target_pos: Vector3, target_rot: Quaternion, duration: float, is_returning: bool
) -> void:
	is_animation_running = true
	if animation_tween:
		animation_tween.kill()

	var start_rot = player_head.global_transform.basis.get_rotation_quaternion()
	animation_tween = create_tween()
	animation_tween.set_parallel(true)
	animation_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	animation_tween.tween_property(player_head, "global_position", target_pos, duration)
	animation_tween.tween_method(_apply_rotation.bind(), start_rot, target_rot, duration)
	animation_tween.finished.connect(_on_tween_completed.bind(is_returning), CONNECT_ONE_SHOT)


func _on_tween_completed(is_returning: bool) -> void:
	is_animation_running = false

	if is_returning:
		player.set_state(Player.State.FREE)
		if is_solved:
			_toggle_drawer_animation()
	else:
		_open_minigame_ui()


func _apply_rotation(rot: Quaternion) -> void:
	var pos = player_head.global_position
	player_head.global_transform = Transform3D(Basis(rot), pos)


func _open_minigame_ui() -> void:
	if not minigame_scene:
		push_warning("DrawerMinigameStarter: Keine 'minigame_scene' im Inspector zugewiesen!")
		return

	_active_minigame = minigame_scene.instantiate()

	if _active_minigame.has_signal("puzzle_solved"):
		_active_minigame.connect("puzzle_solved", _on_minigame_solved)
	if _active_minigame.has_signal("puzzle_cancelled"):
		_active_minigame.connect("puzzle_cancelled", _on_minigame_cancelled)

	get_tree().current_scene.add_child(_active_minigame)


func _on_minigame_solved() -> void:
	is_solved = true
	_active_minigame = null
	_unfocus_camera()


func _on_minigame_cancelled() -> void:
	_active_minigame = null
	_unfocus_camera()


func _toggle_drawer_animation() -> void:
	var anim_to_play: String = _get_target_animation()
	if anim_to_play.is_empty():
		return

	if is_open:
		animation_player.play_backwards(anim_to_play)
		is_open = false
	else:
		animation_player.play(anim_to_play)
		is_open = true


func _get_target_animation() -> String:
	if (
		not drawer_animation_name.is_empty()
		and animation_player.has_animation(drawer_animation_name)
	):
		return drawer_animation_name

	for anim in animation_player.get_animation_list():
		if anim != "RESET":
			return anim

	return ""
