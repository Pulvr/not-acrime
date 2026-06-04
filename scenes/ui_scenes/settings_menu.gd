extends Control

var audio_bus_id

@onready var scaling_label = $"MainContainer/SettingsContainer/LeftContainer/Render Scale/CenterContainer/MarginContainer/Label"
@onready var mouse_sensitivity_label = $"MainContainer/SettingsContainer/LeftContainer/Mouse Sensitivity/CenterContainer/MarginContainer/Label"
@onready var language_label = $"MainContainer/SettingsContainer/LeftContainer/Language/CenterContainer/MarginContainer/Label"
@onready var window_mode_label = $"MainContainer/SettingsContainer/RightContainer/Window Mode/CenterContainer/MarginContainer/Label"
@onready var fov_label = $"MainContainer/SettingsContainer/RightContainer/Field of View/CenterContainer/MarginContainer/Label"
@onready var volume_label = $"MainContainer/SettingsContainer/RightContainer/Volume/CenterContainer/MarginContainer/Label"
@onready var back_to_menu_label = $"MainContainer/Back To Menu/CenterContainer/MarginContainer/Label"

func _ready():
	audio_bus_id = AudioServer.get_bus_index("Master")
	_check_last_scene()
	_set_label_texts()

func _check_last_scene():
	if GlobalSettings.last_scene == "Main Menu":
		back_to_menu_label.text = "Back to Menu"
	elif GlobalSettings.last_scene == "Main Scene":
		back_to_menu_label.text = "Back to Game"

func _set_label_texts():
		scaling_label.text = GlobalSettings.last_render_scale_text
		mouse_sensitivity_label.text = GlobalSettings.last_mouse_sensitivity_text
		language_label.text = GlobalSettings.last_language_text
		window_mode_label.text = GlobalSettings.last_window_mode_text
		fov_label.text = GlobalSettings.last_fov_text
		volume_label.text = GlobalSettings.last_volume_text

func _on_back_to_menu_pressed() -> void:
	if GlobalSettings.last_scene == "Main Menu":
		get_tree().change_scene_to_file("res://scenes/ui_scenes/main_menu.tscn")
	elif GlobalSettings.last_scene == "Main Scene":
		get_tree().change_scene_to_file("res://scenes/main/Main_Scene.tscn")

func _on_scaling_pressed() -> void:
	match get_tree().root.scaling_3d_scale:
		0.25:
			get_tree().root.scaling_3d_scale = 0.5
			scaling_label.text = "Render Scale: 0.50"
		0.50:
			get_tree().root.scaling_3d_scale = 0.75
			scaling_label.text = "Render Scale: 0.75"
		0.75:
			get_tree().root.scaling_3d_scale = 1.0
			scaling_label.text = "Render Scale: 1.00"
		1.00:
			get_tree().root.scaling_3d_scale = 0.25
			scaling_label.text = "Render Scale: 0.25"
	GlobalSettings.last_render_scale_text = scaling_label.text


func _on_mouse_sensitivity_pressed() -> void:
	match GlobalSettings.mouse_sensitivity:
		0.001:
			GlobalSettings.mouse_sensitivity = 0.002
			mouse_sensitivity_label.text = "Mouse Sensitivity: 1.00"
		0.002:
			GlobalSettings.mouse_sensitivity = 0.003
			mouse_sensitivity_label.text = "Mouse Sensitivity: 2.00"
		0.003:
			GlobalSettings.mouse_sensitivity = 0.004
			mouse_sensitivity_label.text = "Mouse Sensitivity: 3.00"
		0.004:
			GlobalSettings.mouse_sensitivity = 0.001
			mouse_sensitivity_label.text = "Mouse Sensitivity: 0.50"
	GlobalSettings.last_mouse_sensitivity_text = mouse_sensitivity_label.text


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
	GlobalSettings.last_window_mode_text = window_mode_label.text


func _on_fov_pressed() -> void:
	match GlobalSettings.field_of_view:
		80.0:
			GlobalSettings.field_of_view = 90
			fov_label.text = "Field of View: 90"
		90.0:
			GlobalSettings.field_of_view = 100
			fov_label.text = "Field of View: 100"
		100.0:
			GlobalSettings.field_of_view = 110
			fov_label.text = "Field of View: 110"
		110.0:
			GlobalSettings.field_of_view = 80
			fov_label.text = "Field of View: 80"
	GlobalSettings.last_fov_text = fov_label.text


func _on_volume_pressed() -> void:
	match volume_label.text:
		"Volume: 0%":
			AudioServer.set_bus_mute(audio_bus_id, false)
			AudioServer.set_bus_volume_db(audio_bus_id, -6)
			volume_label.text = "Volume: 25%"
		"Volume: 25%":
			AudioServer.set_bus_volume_db(audio_bus_id, 0)
			volume_label.text = "Volume: 50%"
		"Volume: 50%":
			AudioServer.set_bus_volume_db(audio_bus_id, 6)
			volume_label.text = "Volume: 75%"
		"Volume: 75%":
			AudioServer.set_bus_volume_db(audio_bus_id, 12)
			volume_label.text = "Volume: 100%"
		"Volume: 100%":
			AudioServer.set_bus_mute(audio_bus_id, true)
			volume_label.text = "Volume: 0%"
	GlobalSettings.last_volume_text = volume_label.text
