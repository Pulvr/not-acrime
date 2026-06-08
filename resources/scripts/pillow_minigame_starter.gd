extends StaticBody3D
"""
Toilet Minigame starter, needed because the collider is checked for interact
so we have to extend the staticbody3d which then loads the UI Scene
Also helpful to load Dialogic stuff
"""
@onready var PIllowUi = preload("res://scenes/ui_scenes/minigames/PillowMiniGame.tscn")
@onready var mainScene = get_tree().get_root().get_node("Main_Scene/Player/UILayer")

signal PillowMiniGameStarted()
signal PillowMiniGameEnded()

func interact():
	if Dialogic.VAR.talked_to_cellmate_1 && Dialogic.VAR.has_sharp:
		startMinigame()
	if Dialogic.current_timeline == null && !Dialogic.VAR.has_sharp:
		Dialogic.start("pillow_minigame_timeline")

func startMinigame():
	PillowMiniGameStarted.emit()
	var uiInstance = PIllowUi.instantiate()
	mainScene.add_child(uiInstance)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	uiInstance.PillowMiniGameUiDeleted.connect(_on_pillow_minigame_ui_delete)
	uiInstance.PillowMiniGameNotAccurateEnough.connect(_on_not_accurate)

func _on_pillow_minigame_ui_delete():
	PillowMiniGameEnded.emit()

func _on_not_accurate():
	print("not ACCURATE")
