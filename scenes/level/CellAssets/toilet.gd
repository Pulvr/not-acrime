extends StaticBody3D

@onready var ToiletUi = preload("res://scenes/main/minigames/ToiletMiniGame.tscn")
@onready var mainScene = get_tree().get_root().get_node("Main_Scene/Player/UILayer")

signal ToiletMiniGameStarted()
signal ToiletMiniGameEnded()

var interaced_with = false

func interact():
	if Dialogic.VAR.talked_to_cellmate_1 && !Dialogic.VAR.has_sharp:
		startMinigame()
	elif Dialogic.current_timeline == null:
		Dialogic.start("toilet_minigame_timeline")

func startMinigame():
	ToiletMiniGameStarted.emit()
	var uiInstance = ToiletUi.instantiate()
	mainScene.add_child(uiInstance)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	uiInstance.ToiletMiniGameUiDeleted.connect(_on_toilet_minigame_ui_delete)

func _on_toilet_minigame_ui_delete():
	ToiletMiniGameEnded.emit()
	interaced_with = true
