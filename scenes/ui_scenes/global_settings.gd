extends Node

signal global_settings_changed  #used by settings_menu.gd

enum LastScenes {
	MAIN_MENU,
	MAIN_SCENE,
	INPUT_MENU,
	SETTINGS_MENU,
}

var mouse_sensitivity: float = 0.002
var field_of_view: float = 90
var last_scene: LastScenes

var last_render_scale_text: String = "Render Scale: 1.00"
var last_mouse_sensitivity_text: String = "Mouse Sensitivity: 1.00"
var last_language_text: String = "Language: English"
var last_window_mode_text: String = "Window Mode: Windowed"
var last_fov_text: String = "Field of View: 90"
var last_volume_text: String = "Volume: 50%"


func set_last_scene(new_last_scene: LastScenes) -> void:
	last_scene = new_last_scene
