extends AudioStreamPlayer3D

@export var footstep_sounds: Array[AudioStream] = []


func play_footstep_sound():
	if footstep_sounds.is_empty():
		return

	var random_index: int = randi() % footstep_sounds.size()
	var chosen_sound: AudioStream = footstep_sounds[random_index]
	stream = chosen_sound
	pitch_scale = randf_range(0.95, 1.05)
	play()


func _on_footstep_timer_timeout() -> void:
	play_footstep_sound()


func _on_player_node_player_stopped() -> void:
	if not $FootstepTimer.is_stopped():
		$FootstepTimer.stop()


func _on_player_node_player_moved() -> void:
	if $FootstepTimer.is_stopped():
		play_footstep_sound()
		$FootstepTimer.start()
