extends PathFollow3D

enum DroneMode { DETECTING, STOPPED }

var current_mode: DroneMode = DroneMode.DETECTING

@export var speed: float = 5.0


func _process(delta: float) -> void:
	if current_mode == DroneMode.DETECTING:
		progress += speed * delta


func _on_drone_player_detected() -> void:
	current_mode = DroneMode.STOPPED
