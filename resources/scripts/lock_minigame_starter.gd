extends StaticBody3D
const LOCK_MINIGAME_SCENE = preload("res://scenes/ui_scenes/minigames/cell_lock_minigame.tscn")
@export var timeline: DialogicTimeline

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_dialogic_signal(argument: String) -> void:
	if argument == "start_cell_lock_minigame":
		print("start")
		start_minigame()

func interact():
	if Dialogic.current_timeline == null:
		Dialogic.start(timeline)

func start_minigame():
	var minigame_instance = LOCK_MINIGAME_SCENE.instantiate()
	minigame_instance.minigame_won.connect(_on_door_opened)
	minigame_instance.minigame_failed.connect(_on_door_still_closed)
	get_tree().root.add_child(minigame_instance)
	get_tree().paused = true

func _on_door_opened():
	var lock_collider = get_tree().get_first_node_in_group("lock_collider")
	if lock_collider:
		lock_collider.disabled = true
	get_tree().paused = false

func _on_door_still_closed():
	Dialogic.start("door_lock_minigame_failed_timeline")
	get_tree().paused = false
