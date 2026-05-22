extends StaticBody3D

@onready var ToiletUi = preload("res://scenes/main/minigames/ToiletMiniGame.tscn")
@onready var mainScene = get_tree().get_root().get_node("Main_Scene/Player/UILayer")
var uiInstance

signal ToiletMiniGameStarted();
signal ToiletMiniGameEnded();

func interact():

	startMinigame()
	await get_tree().create_timer(1).timeout
	endMiniGamee()


func startMinigame():
	ToiletMiniGameStarted.emit()
	uiInstance = ToiletUi.instantiate()
	mainScene.add_child(uiInstance)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func endMiniGamee():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	uiInstance.queue_free()
	ToiletMiniGameEnded.emit()
