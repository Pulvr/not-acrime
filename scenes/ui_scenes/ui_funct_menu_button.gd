@tool
extends MarginContainer

@export var text: String = "Button":
	set(value):
		text = value
		if has_node("CenterContainer/MarginContainer/Label"):
			$CenterContainer/MarginContainer/Label.text = value

@export var disabled: bool = false:
	set(value):
		disabled = value
		update_appearance()

var color_background_normal = Color("707070")
var color_background_clicked = Color("DADADA")
var color_frame_normal = Color("5A5A5A")
var color_frame_hovered = Color("D3D3D3")

@onready var background = $Background
@onready var border = $Border
@onready var click_logic = $"Click Logic"
@onready var label = $CenterContainer/MarginContainer/Label
@onready var hover_sound = $AudioStreamPlayer

func _ready():
	$CenterContainer/MarginContainer/Label.text = text
	update_appearance()

func update_appearance():
	if not is_node_ready():
		return
	click_logic.disabled = disabled

	if disabled:
		background.self_modulate = color_background_normal
		background.modulate.a = 0.5
		border.self_modulate = color_frame_normal
		border.modulate.a = 0.5
		label.modulate.a = 0.5

	else:
		background.self_modulate = color_background_normal
		background.modulate.a = 1.0
		border.self_modulate = color_frame_normal
		border.modulate.a = 1.0
		label.modulate.a = 1.0


func _on_click_logic_mouse_entered() -> void:
	if disabled:
		return
	border.self_modulate = color_frame_hovered
	hover_sound.play()


func _on_click_logic_mouse_exited() -> void:
	border.self_modulate = color_frame_normal


func _on_click_logic_button_down() -> void:
	background.self_modulate = color_background_clicked


func _on_click_logic_button_up() -> void:
	background.self_modulate = color_background_normal
