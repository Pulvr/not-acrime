extends Area3D

@export var stop_player_duration = 2
@export var fade_to_black_duration = 1.5

var triggered: bool = false
var movement_tween: Tween

@onready var fadeRect = get_tree().get_first_node_in_group("canvas_layer")
func _on_body_entered(body: Node3D) -> void:
	if triggered or not body.is_in_group("player"):
		return
	triggered = true
	print("Player entered the trigger!")
	#Fadeout here
	#Play sound
	_stop_player_smoothly(stop_player_duration)
	await fadeRect.fade_to_black(fade_to_black_duration)
	get_tree().change_scene_to_file("res://scenes/main/demo_end_screen.tscn")

func _stop_player_smoothly(duration: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	player.hint_checker = !player.hint_checker
	player.interact_hint.visible = !player.interact_hint.visible
	if movement_tween:
		movement_tween.kill()
	movement_tween = create_tween()
	movement_tween.set_parallel(true)
	movement_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	movement_tween.tween_property(player, "SPEED", 0.0, duration)
