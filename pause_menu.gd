extends Control

const CONTROLS_MENU_SCENE = preload("res://scenes/ui_scenes/controls_menu.tscn")

@onready var player = get_tree().get_first_node_in_group("player")

func _on_continue_pressed():
	get_tree().paused = false
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	player.set_state(Player.State.FREE)

func _on_controls_pressed() -> void:
	GlobalSettings.set_last_scene(GlobalSettings.LastScenes.MAIN_SCENE)
	var controls = CONTROLS_MENU_SCENE.instantiate()
	add_child(controls)

func _on_settings_pressed() -> void:
	GlobalSettings.set_last_scene(GlobalSettings.LastScenes.MAIN_SCENE)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui_scenes/settings_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("ui_cancel") and get_tree().paused:
		_on_continue_pressed()
		get_viewport().set_input_as_handled()

func _on_main_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/ui_scenes/main_menu.tscn")
