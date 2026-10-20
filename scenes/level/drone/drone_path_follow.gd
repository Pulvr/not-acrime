extends PathFollow3D

@export var speed: float = 5.0


func _process(delta: float) -> void:
	if $Drone.current_state == $Drone.DroneState.DETECTING:
		progress += speed * delta
