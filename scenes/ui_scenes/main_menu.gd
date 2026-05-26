extends Control

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/intro_clip.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
