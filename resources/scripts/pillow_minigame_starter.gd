extends StaticBody3D
"""
Toilet Minigame starter, needed because the collider is checked for interact
so we have to extend the staticbody3d which then loads the UI Scene
Also helpful to load Dialogic stuff
"""
@onready var PIllowUi = preload("res://scenes/ui_scenes/minigames/PillowMiniGame.tscn")
@onready var mainScene = get_tree().get_root().get_node("Main_Scene/Player/UILayer")
@onready var pillow= $Bunkbed/bunkbed
@onready var pillow_ripped = $Bunkbed/bunkbed_ripped
var uiInstance = null

signal PillowMiniGameStarted()
signal PillowMiniGameEnded()

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument: String) -> void:
	if argument == "start_pillow_minigame":
		_on_start_pillow_minigame()

func interact():
	if Dialogic.current_timeline == null:
		Dialogic.start("pillow_timeline")

func _on_start_pillow_minigame():
	for child in mainScene.get_children(): #needed check in main tree, for whatever reason the scene is instatiated three times???
			if child.name == "PillowMiniGame":
				return
				
	PillowMiniGameStarted.emit()
	uiInstance = PIllowUi.instantiate()
	mainScene.add_child(uiInstance)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	uiInstance.PillowMiniGameUiDeleted.connect(_on_pillow_minigame_ui_delete)

func _on_pillow_minigame_ui_delete():
	Dialogic.signal_event.disconnect(_on_dialogic_signal)
	PillowMiniGameEnded.emit()
	pillow_ripped.visible=true
	pillow.visible=false
