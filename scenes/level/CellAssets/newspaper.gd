extends StaticBody3D


@export var move_duration: float = 2
@export var view_distance: float = 1.4

@onready var player = get_tree().get_first_node_in_group("player")
@onready var player_head = player.head
@onready var newspaper_fake_light = get_node("../../../Lighting/cell_own/newspaper_light")

var original_position: Vector3
var original_rotation: Quaternion
var is_focused: bool = false
var is_animation_running: bool = false
var animation_tween: Tween
var light_tween: Tween

func interact():
	if is_animation_running:
		return
		
	if is_focused:
		_animate_head(original_position, original_rotation, move_duration, true)
		_toggle_newspaper_light(0)
	else:
		original_position = player_head.global_position
		original_rotation = player_head.global_transform.basis.get_rotation_quaternion()
		
		var target_pos = global_position + global_transform.basis.x * view_distance
		
		var forward = (global_position - target_pos).normalized()
		var target_rot = Basis.looking_at(forward, Vector3.UP).get_rotation_quaternion()
		target_pos += Vector3(0, 0.75, 0)

		player.set_state(Player.State.IN_DIALOGUE)
		_animate_head(target_pos, target_rot, move_duration, false)
		_toggle_newspaper_light(1)
		
	is_focused = !is_focused

func _animate_head(target_pos: Vector3, target_rot: Quaternion, duration: float, is_returning: bool):
	is_animation_running = true
	player.set_state(Player.State.IN_DIALOGUE)
	if animation_tween:
		animation_tween.kill()
		
	var start_rot = player_head.global_transform.basis.get_rotation_quaternion()
	animation_tween = create_tween()
	animation_tween.set_parallel(true)
	animation_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	animation_tween.tween_property(player_head, "global_position", target_pos, duration)
	animation_tween.tween_method(_apply_rotation.bind(), start_rot, target_rot, duration)
	animation_tween.finished.connect(_on_tween_completed.bind(is_returning), CONNECT_ONE_SHOT)

func _on_tween_completed(is_returning: bool):
	is_animation_running = false
	if is_returning:
		player.set_state(Player.State.FREE)
	
func _apply_rotation(rot: Quaternion) -> void:
	var pos = player_head.global_position
	player_head.global_transform = Transform3D(Basis(rot), pos)
	
func _toggle_newspaper_light(light_energy: float):
	if light_tween:
		light_tween.kill()
	light_tween = create_tween()
	light_tween.set_parallel(true)
	light_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	light_tween.tween_property(newspaper_fake_light, "light_energy", light_energy, move_duration)
	
