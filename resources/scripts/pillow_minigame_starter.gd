extends StaticBody3D

## Toilet Minigame starter, needed because the collider is checked for interact
## so we have to extend the staticbody3d which then loads the UI Scene
## Also helpful to load Dialogic stuff

var ui_instance = null

@onready var PillowUi = preload("res://scenes/ui_scenes/minigames/pillow_minigame.tscn")
@onready var main_scene = get_tree().get_root().get_node("MainScene/Player/UILayer")
@onready var pillow= $Bunkbed/Bunkbed
@onready var pillow_ripped = $Bunkbed/BunkbedRipped

signal pillow_minigame_started()
signal pillow_minigame_ended()

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument: String) -> void:
	if argument == "start_pillow_minigame":
		_on_start_pillow_minigame()

func interact():
	if Dialogic.current_timeline == null:
		Dialogic.start("pillow_timeline")

func _on_start_pillow_minigame():
	for child in main_scene.get_children(): #needed check in main tree, for whatever reason the scene is instantiated three times???
			if child.name == "PillowMinigame":
				return
				
	pillow_minigame_started.emit()
	ui_instance = PillowUi.instantiate()
	main_scene.add_child(ui_instance)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	ui_instance.pillow_minigame_ui_deleted.connect(_on_pillow_minigame_ui_delete)

func _on_pillow_minigame_ui_delete():
	Dialogic.signal_event.disconnect(_on_dialogic_signal)
	pillow_minigame_ended.emit()
	pillow_ripped.visible=true
	pillow.visible=false
