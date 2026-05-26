extends Control

@onready var button = $"Menu Button/Click Logic"
@onready var disgustBar = $"ProgressBarContainer/ProgressBar"

@export var decline_rate = 15
@export var click_reward = 5
var current_bar_value = 0

signal ToiletMiniGameUiDeleted()

func _ready():
    button.pressed.connect(_on_button_pressed)

func _on_button_pressed():
    current_bar_value += click_reward
    disgustBar.value = current_bar_value
    if disgustBar.value >= 100.0:
        endMiniGame()

func _physics_process(delta: float) -> void:
    current_bar_value -= decline_rate * delta
    current_bar_value = max(current_bar_value, 0)
    print(current_bar_value)
    disgustBar.value = current_bar_value

func endMiniGame():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
    ToiletMiniGameUiDeleted.emit()
    queue_free()