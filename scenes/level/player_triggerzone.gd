extends Area3D

var triggered := false

func _on_body_entered(body: Node3D) -> void:
	if triggered or not body.is_in_group("player"):
		return
	triggered = true
	print("Player entered the trigger!")
		# trigger your event here
