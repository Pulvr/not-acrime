extends StaticBody3D
"""
Toilet Minigame starter, needed because the collider is checked for interact
so we have to extend the staticbody3d which then loads the UI Scene
Also helpful to load Dialogic stuff
"""
@onready var PIllowUi = preload("res://scenes/ui_scenes/minigames/PillowMiniGame.tscn")
@onready var mainScene = get_tree().get_root().get_node("Main_Scene/Player/UILayer")
@onready var pillow_ripped = $Bunkbed/bunkbed_ripped
var uiInstance = null

signal PillowMiniGameStarted()
signal PillowMiniGameEnded()

func interact():
	if Dialogic.current_timeline == null && Dialogic.VAR.talked_to_cellmate_1 && Dialogic.VAR.has_sharp && !Dialogic.VAR.has_key:
		startMinigame()
	elif Dialogic.current_timeline == null && !Dialogic.VAR.has_sharp || Dialogic.VAR.has_key:
		Dialogic.start("pillow_minigame_timeline")

func startMinigame():
	PillowMiniGameStarted.emit()
	if uiInstance == null:
		uiInstance = PIllowUi.instantiate()
		mainScene.add_child(uiInstance)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		uiInstance.PillowMiniGameUiDeleted.connect(_on_pillow_minigame_ui_delete)

func _on_pillow_minigame_ui_delete():
	PillowMiniGameEnded.emit()
	pillow_ripped.visible=true
