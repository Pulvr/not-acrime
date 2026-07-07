extends Area3D

@export var stop_player_duration = 1

var triggered: bool = false
var movement_tween: Tween

@onready var gun_shot_sound = $GunShotAudioPlayer

func _on_body_entered(body: Node3D) -> void:
	if triggered or not body.is_in_group("player"):
		return
	triggered = true
	
	_stop_player_smoothly(stop_player_duration)
	await FadeLayer.fade_to_black(1.5)
	gun_shot_sound.play()
	await gun_shot_sound.finished
	FadeLayer.change_scene("res://scenes/main/demo_end_screen.tscn")

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
