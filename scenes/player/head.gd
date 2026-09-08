extends Node3D


func look_at_target_with_offset(target_node: Node, min_camera_x: float, max_camera_x: float):
	var collision_shape: Node = target_node.get_node_or_null("CollisionShape3D")
	var target_height: float = 0.0
	if collision_shape and collision_shape.shape:
		target_height = collision_shape.shape.height

	var adjusted_target_pos = target_node.global_position
	adjusted_target_pos.y += (target_height / 2.0)

	var direction = adjusted_target_pos - global_position
	if direction.length_squared() < 0.01:
		return

	var horizontal_distance: float = Vector2(direction.x, direction.z).length()
	var angle_x: float = atan2(direction.y, horizontal_distance)
	var angle_y: float = atan2(-direction.x, -direction.z)

	var player: Node = owner
	if player:
		player.global_rotation.y = angle_y

	rotation.x = clamp(angle_x, min_camera_x, max_camera_x)
	rotation.y = 0.0
	rotation.z = 0.0
