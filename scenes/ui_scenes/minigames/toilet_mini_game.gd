extends Control

@onready var button = $"Menu Button/Click Logic"
@onready var disgustBar = $"ProgressBarContainer/ProgressBar"
@onready var lmb_icon = $"LeftMouse"
@onready var rmb_icon = $"RightMouse"
@onready var splash_player = $SplashSoundPlayer
@onready var success_player = $SuccessSoundPlayer

@export var decline_rate = 15
@export var click_reward = 3
var current_bar_value = 0

var lmb_last_pressed = false
var rmb_last_pressed = true

var click_count = 0
var game_ended = false
var splash_sound_intervall = 10 # Clicks we need to play a splash sound

signal ToiletMiniGameUiDeleted()

func _physics_process(delta: float) -> void:
	current_bar_value -= decline_rate * delta
	current_bar_value = max(current_bar_value, 0)
	disgustBar.value = current_bar_value

func endMiniGame():
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	success_player.play()
	await success_player.finished
	ToiletMiniGameUiDeleted.emit()
	queue_free()


func _on_click_logic_gui_input(event: InputEvent) -> void:
	if game_ended:
		return
	if event is InputEventMouseButton:
		var valid_click = false
		if event.button_index == 1 and rmb_last_pressed and event.pressed:
			current_bar_value += click_reward
			disgustBar.value = current_bar_value
			lmb_last_pressed = true
			rmb_last_pressed = false
			lmb_icon.visible = false
			rmb_icon.visible = true
			valid_click = true
		if event.button_index == 2 and lmb_last_pressed and event.pressed: 
			current_bar_value += click_reward
			disgustBar.value = current_bar_value
			rmb_last_pressed = true
			lmb_last_pressed = false
			lmb_icon.visible = true
			rmb_icon.visible = false
			valid_click = true
		if valid_click:
			click_count += 1
			if click_count % splash_sound_intervall == 0:
				splash_player.pitch_scale = randf_range(0.9, 1.1)
				splash_player.play()
	if disgustBar.value >= 100.0 and not game_ended:
		game_ended = true
		endMiniGame()
