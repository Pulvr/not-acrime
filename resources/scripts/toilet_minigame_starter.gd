extends StaticBody3D

## Toilet Minigame starter, needed because the collider is checked for interact
## so we have to extend the staticbody3d which then loads the UI Scene
## Also helpful to load Dialogic stuff

signal toilet_minigame_started
signal toilet_minigame_ended

var ui_instance = null

@onready var ToiletUI = preload("res://scenes/ui_scenes/minigames/toilet_minigame.tscn")
@onready var main_scene = get_tree().get_root().get_node("MainScene/Player/UILayer")


func interact():
	if Dialogic.VAR.talked_to_cellmate_1 && !Dialogic.VAR.has_sharp:
		startMinigame()
	elif Dialogic.current_timeline == null:
		Dialogic.start("toilet_minigame_timeline")


func startMinigame():
	toilet_minigame_started.emit()
	if ui_instance == null:
		ui_instance = ToiletUI.instantiate()
		main_scene.add_child(ui_instance)
		ui_instance.toilet_minigame_ui_deleted.connect(_on_toilet_minigame_ui_delete)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_toilet_minigame_ui_delete():
	toilet_minigame_ended.emit()
