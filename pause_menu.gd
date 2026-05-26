extends Control

func _on_continue_pressed():
	get_tree().paused = false
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _on_quit_pressed():
	get_tree().quit()
