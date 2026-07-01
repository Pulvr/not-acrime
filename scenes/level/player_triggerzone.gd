extends Area3D

var triggered := false

@onready var fadeRect = get_tree().get_first_node_in_group("canvas_layer")
func _on_body_entered(body: Node3D) -> void:
	if triggered or not body.is_in_group("player"):
		return
	triggered = true
	print("Player entered the trigger!")
	#Fadeout here
	#Play sound
	#PlayerMovement hier mit Tween langsamer machen
	await fadeRect.fade_to_black(1.5)
	get_tree().change_scene_to_file("res://scenes/main/demo_end_screen.tscn")
