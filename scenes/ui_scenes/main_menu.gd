extends Control


func _on_start_pressed() -> void:
	reset_game()
	GlobalSettings.set_last_scene(GlobalSettings.LastScenes.MAIN_MENU)
	FadeLayer.change_scene("res://scenes/main/intro_clip.tscn", 2, false)


func _on_controls_pressed() -> void:
	GlobalSettings.set_last_scene(GlobalSettings.LastScenes.MAIN_MENU)
	get_tree().change_scene_to_file("res://scenes/ui_scenes/controls_menu.tscn")


func _on_settings_pressed() -> void:
	GlobalSettings.set_last_scene(GlobalSettings.LastScenes.MAIN_MENU)
	get_tree().change_scene_to_file("res://scenes/ui_scenes/settings_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func reset_game():
	Dialogic.VAR.reset()
