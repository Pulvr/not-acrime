extends StaticBody3D

@export var timeline: DialogicTimeline
@export var has_lock_minigame: bool = false

const LOCK_MINIGAME_SCENE = preload("res://scenes/ui_scenes/minigames/cell_lock_minigame.tscn")

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)

func startDialog():
	if timeline != null and Dialogic.current_timeline == null:
		Dialogic.start(timeline)
	elif Dialogic.current_timeline != null:
		print("Dialogue already running")
	else:
		print("No dialog attached to this NPC")

func _on_dialogic_signal(argument: String) -> void:
	if not has_lock_minigame:
		return
	if argument == "start_cell_lock_minigame":
		start_minigame()

func start_minigame():
	var minigame_instance = LOCK_MINIGAME_SCENE.instantiate()
	minigame_instance.minigame_won.connect(_on_door_opened)
	minigame_instance.minigame_failed.connect(_on_door_still_closed)
	get_tree().root.add_child(minigame_instance)
	get_tree().paused = true

func _on_door_opened():
	get_tree().change_scene_to_file("res://scenes/main/demo_end_screen.tscn")
	#alternativ: get_tree().paused = false

func _on_door_still_closed():
	Dialogic.start("door_lock_minigame_failed_timeline")
	get_tree().paused = false
