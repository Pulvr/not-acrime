extends Control

func _on_start_pressed() -> void:
	reset_game()
	GlobalSettings.last_scene = "Main Menu"
	get_tree().change_scene_to_file("res://scenes/main/intro_clip.tscn")

func _on_controls_pressed() -> void:
	GlobalSettings.last_scene = "Main Menu"
	get_tree().change_scene_to_file("res://scenes/ui_scenes/controls_menu.tscn")

func _on_settings_pressed() -> void:
	GlobalSettings.last_scene = "Main Menu"
	get_tree().change_scene_to_file("res://scenes/ui_scenes/settings_menu.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func reset_game():
	Dialogic.VAR.reset()
