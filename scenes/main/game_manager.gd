extends Node

@onready var player: Node = $Player
@onready var drone: Node = $LevelAssets/Hallway/DronePath3D/DronePathFollow/Drone


func _ready() -> void:
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	drone.player_detected.connect(_on_drone_player_detected)

	await get_tree().process_frame
	if GlobalSettings.last_scene != GlobalSettings.LastScenes.SETTINGS_MENU:
		pass
		player.auto_start_intro_dialog()


func _on_timeline_started():
	player.set_state(Player.State.IN_DIALOGUE)


func _on_timeline_ended():
	if !player.get_state() == Player.State.IN_MINIGAME:
		player.set_state(Player.State.FREE)


func _on_drone_player_detected() -> void:
	player.head.look_at_target_with_offset(drone)
