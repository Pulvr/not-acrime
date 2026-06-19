extends Control

func _on_back_to_menu_pressed():
	if GlobalSettings.last_scene == "Main Menu":
		GlobalSettings.last_scene = "Input Menu"
		get_tree().change_scene_to_file("res://scenes/ui_scenes/main_menu.tscn")

	elif GlobalSettings.last_scene == "Main Scene":
		queue_free()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_to_menu_pressed() # you can escape from controls menu but not from prison
