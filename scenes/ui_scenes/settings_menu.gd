extends Control

@onready var scaling_label = $"MainContainer/SettingsContainer/LeftContainer/Render Scale/CenterContainer/MarginContainer/Label"
@onready var window_mode_label = $"MainContainer/SettingsContainer/RightContainer/Window Mode/CenterContainer/MarginContainer/Label"

func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui_scenes/main_menu.tscn")

func _on_scaling_pressed() -> void:
	match scaling_label.text:
		"Render Scale: 0.25":
			print(0.25)
			scaling_label.text = "Render Scale: 0.50"
		"Render Scale: 0.50":
			print(0.50)
			scaling_label.text = "Render Scale: 0.75"
		"Render Scale: 0.75":
			print(0.75)
			scaling_label.text = "Render Scale: 1.00"
		"Render Scale: 1.00":
			print(1.00)
			scaling_label.text = "Render Scale: 0.25"


func _on_pointer_speed_pressed() -> void:
	pass

func _on_language_pressed() -> void:
	pass

func _on_window_mode_pressed() -> void:
	match DisplayServer.window_get_mode():
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			window_mode_label.text = "Window Mode: Fullscreen"
		3:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			window_mode_label.text = "Window Mode: Windowed"


func _on_fov_pressed() -> void:
	pass

func _on_volume_pressed() -> void:
	pass
