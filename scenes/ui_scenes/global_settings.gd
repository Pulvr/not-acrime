extends Node

var mouse_sensitivity: float = 0.002
var field_of_view: float = 90
var last_scene: String

var last_render_scale_text: String = "Render Scale: 1.00"
var last_mouse_sensitivity_text: String = "Mouse Sensitivity: 1.00"
var last_language_text: String = "Language: English"
var last_window_mode_text: String = "Window Mode: Windowed"
var last_fov_text: String = "Field of View: 90"
var last_volume_text: String = "Volume: 50%"

# Player Position
var last_player_position: Vector3
var last_player_rotation: Vector3
var last_head_rotation: Vector3
# I think this might be a persistent inventory, but it could also break very easily
var last_inventory: Array[ItemData] = []
var last_selected_index: int = 0
