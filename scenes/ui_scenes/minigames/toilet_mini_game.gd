extends Control

@onready var button = $"Menu Button/Click Logic"
@onready var disgustBar = $"ProgressBarContainer/ProgressBar"
@onready var lmb_icon = $"LeftMouse"
@onready var rmb_icon = $"RightMouse"

@export var decline_rate = 15
@export var click_reward = 3
var current_bar_value = 0

var lmb_last_pressed = false
var rmb_last_pressed = true

signal ToiletMiniGameUiDeleted()

func _physics_process(delta: float) -> void:
	current_bar_value -= decline_rate * delta
	current_bar_value = max(current_bar_value, 0)
	disgustBar.value = current_bar_value

func endMiniGame():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ToiletMiniGameUiDeleted.emit()
	queue_free()


func _on_click_logic_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == 1 and rmb_last_pressed and event.pressed:
			current_bar_value += click_reward
			disgustBar.value = current_bar_value
			lmb_last_pressed = true
			rmb_last_pressed = false
			lmb_icon.visible = false
			rmb_icon.visible = true
		if event.button_index == 2 and lmb_last_pressed and event.pressed: 
			current_bar_value += click_reward
			disgustBar.value = current_bar_value
			rmb_last_pressed = true
			lmb_last_pressed = false
			lmb_icon.visible = true
			rmb_icon.visible = false
	if disgustBar.value >= 100.0:
		endMiniGame()
