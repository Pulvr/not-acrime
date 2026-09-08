extends Control

signal toilet_minigame_ui_deleted

@export var decline_rate: int = 15
@export var click_reward: int = 3

var current_bar_value: float = 0.0
var lmb_last_pressed: bool = false
var rmb_last_pressed: bool = true

var click_count: int = 0
var game_ended: bool = false
var splash_sound_intervall: int = 10  # Clicks we need to play a splash sound

@onready var button = $"ClickLogic"
@onready var disgust_bar = $"ProgressBarContainer/ProgressBar"
@onready var mouse_icon = %MouseIcon
@onready var splash_player = $SplashSoundPlayer
@onready var success_player = $SuccessSoundPlayer


func _physics_process(delta: float) -> void:
	current_bar_value -= decline_rate * delta
	current_bar_value = max(current_bar_value, 0)
	disgust_bar.value = current_bar_value


func end_minigame():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	success_player.play()
	await success_player.finished
	toilet_minigame_ui_deleted.emit()
	queue_free()


func _on_click_logic_gui_input(event: InputEvent) -> void:
	if game_ended:
		return
	if event is InputEventMouseButton:
		var valid_click: bool = false
		if event.button_index == 1 and rmb_last_pressed and event.pressed:
			current_bar_value += click_reward
			disgust_bar.value = current_bar_value
			lmb_last_pressed = true
			rmb_last_pressed = false
			mouse_icon.flip_h = true
			valid_click = true
		if event.button_index == 2 and lmb_last_pressed and event.pressed:
			current_bar_value += click_reward
			disgust_bar.value = current_bar_value
			rmb_last_pressed = true
			lmb_last_pressed = false
			mouse_icon.flip_h = false
			valid_click = true
		if valid_click:
			click_count += 1
			if click_count % splash_sound_intervall == 0:
				splash_player.pitch_scale = randf_range(0.9, 1.1)
				splash_player.play()
	if disgust_bar.value >= 100.0 and not game_ended:
		game_ended = true
		end_minigame()
