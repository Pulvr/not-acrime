class_name Drone
extends StaticBody3D

signal player_detected

enum DroneState { DETECTING, STOPPED }

var current_state: DroneState = DroneState.DETECTING

@onready var shape_cast: ShapeCast3D = $PlayerDetectorShape
@onready var detect_player: AudioStreamPlayer3D = $DetectedPlayer


func _physics_process(_delta: float) -> void:
	if shape_cast.is_colliding() and current_state == DroneState.DETECTING:
		var collider: Object = shape_cast.get_collider(0)

		if collider and collider.is_in_group("player"):
			player_detected.emit()
			print("detected")


func set_state(new_mode: DroneState) -> void:
	current_state = new_mode


func get_state() -> DroneState:
	return current_state


func _on_player_detected() -> void:
	current_state = DroneState.STOPPED
	detect_player.play()
	await detect_player.finished
	current_state = DroneState.DETECTING
