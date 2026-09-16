extends StaticBody3D

signal player_detected

@onready var shape_cast: ShapeCast3D = $PlayerDetectorShape


func _physics_process(_delta: float) -> void:
	if shape_cast.is_colliding():
		var collider: Object = shape_cast.get_collider(0)

		if collider and collider.is_in_group("player"):
			player_detected.emit()
