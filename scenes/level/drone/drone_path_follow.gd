extends PathFollow3D

# Movement speed in meters per second
@export var speed: float = 5.0

func _process(delta: float) -> void:
	progress += speed * delta