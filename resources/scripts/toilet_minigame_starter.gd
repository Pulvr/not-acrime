extends StaticBody3D
"""
Toilet Minigame starter, needed because the collider is checked for interact
so we have to extend the staticbody3d which then loads the UI Scene
Also helpful to load Dialogic stuff
"""
@onready var ToiletUi = preload("res://scenes/ui_scenes/minigames/ToiletMiniGame.tscn")
@onready var mainScene = get_tree().get_root().get_node("Main_Scene/Player/UILayer")
var uiInstance = null

signal ToiletMiniGameStarted()
signal ToiletMiniGameEnded()

func interact():
	if Dialogic.VAR.talked_to_cellmate_1 && !Dialogic.VAR.has_sharp:
		startMinigame()
	elif Dialogic.current_timeline == null:
		Dialogic.start("toilet_minigame_timeline")

func startMinigame():
	ToiletMiniGameStarted.emit()
	if uiInstance == null:
		uiInstance = ToiletUi.instantiate()
		mainScene.add_child(uiInstance)
		uiInstance.ToiletMiniGameUiDeleted.connect(_on_toilet_minigame_ui_delete)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_toilet_minigame_ui_delete():
	ToiletMiniGameEnded.emit()
