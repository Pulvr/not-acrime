extends Node

@onready var player: Node = $Player
@onready var drone: Node = $LevelAssets/Hallway/DronePath3D/DronePathFollow/Drone


func _ready() -> void:
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	drone.player_detected.connect(_on_drone_player_detected)

	await get_tree().process_frame
	if GlobalSettings.last_scene != GlobalSettings.LastScenes.SETTINGS_MENU and !DebugController.skip_intro:
		player.auto_start_intro_dialog()


func _on_timeline_started():
	player.set_state(Player.State.IN_DIALOGUE)


func _on_timeline_ended():
	if !player.get_state() == Player.State.IN_MINIGAME:
		player.set_state(Player.State.FREE)


func _on_drone_player_detected() -> void:
	_teleport_player_to_cell()


func _teleport_player_to_cell() -> void:
	player.head.look_at_target_with_offset(drone)
	player.set_state(Player.State.IN_DIALOGUE)
	await FadeLayer.fade_to_black(1.5)
	player.set_position(Vector3(0, 1.6, 1.7))  # Home Pos in Cell
	player.head.look_at_target_with_offset($LevelAssets/RedCell/CellBars)
	await FadeLayer.fade_from_black(1.5)
	if Dialogic.current_timeline == null:
		Dialogic.start("drone_detect_timeline")
