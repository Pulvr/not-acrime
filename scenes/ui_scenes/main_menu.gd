extends Control

func _on_start_pressed() -> void:
	reset_game()
	get_tree().change_scene_to_file("res://scenes/main/intro_clip.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui_scenes/settings_menu.tscn")
	GlobalSettings.last_scene = "Main Menu"

func _on_quit_pressed() -> void:
	get_tree().quit()


func reset_game():
	Dialogic.VAR.set_variable("has_sharp", false)
	Dialogic.VAR.set_variable("talked_to_cellmate_1", false)
	Dialogic.VAR.set_variable("talked_to_cellmate_with_sharp", false)
