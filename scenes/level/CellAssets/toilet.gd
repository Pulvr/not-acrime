extends StaticBody3D

@onready var ToiletUi = preload("res://scenes/main/minigames/ToiletMiniGame.tscn")
@onready var mainScene = get_tree().get_root().get_node("Main_Scene/Player/UILayer")
var uiInstance
var button
var disgustBar

signal ToiletMiniGameStarted();
signal ToiletMiniGameEnded();

func interact():
	startMinigame()

func startMinigame():
	ToiletMiniGameStarted.emit()
	uiInstance = ToiletUi.instantiate()
	button = uiInstance.get_child(0).get_node("Click Logic")
	disgustBar = uiInstance.get_child(1).get_node("ProgressBar")
	button.pressed.connect(_on_button_pressed)
	mainScene.add_child(uiInstance)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_button_pressed():
	disgustBar.value += disgustBar.step
	if disgustBar.value > 100.0:
		endMiniGame()

func endMiniGame(): # cleanup
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	uiInstance.queue_free()
	ToiletMiniGameEnded.emit()

func _process(delta: float) -> void:
	if is_instance_valid(disgustBar) and disgustBar.value > 0.0:
		disgustBar.value -= 3 * delta