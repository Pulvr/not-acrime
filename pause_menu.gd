extends Control

func _on_continue_pressed():
	get_tree().paused = false
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_settings_pressed() -> void:
	GlobalSettings.last_scene = "Main Scene"
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui_scenes/settings_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("ui_cancel") and get_tree().paused:
		_on_continue_pressed()
		get_viewport().set_input_as_handled()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui_scenes/main_menu.tscn")
