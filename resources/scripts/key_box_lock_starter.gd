class_name KeyBoxLockStarter
extends StaticBody3D

signal keybox_minigame_started
signal keybox_minigame_ended

@export var lock_ui_scene: PackedScene = preload("res://scenes/ui_scenes/minigames/key_box_number_lock.tscn")
@export var open_animation_name: String = "keybox_open"

var saved_combination: Array[int] = [0, 0, 0, 0]
var is_unlocked: bool = false
var active_ui: KeyBoxNumberLock = null

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func interact() -> void:
	if is_unlocked or active_ui != null:
		return

	keybox_minigame_started.emit()

	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var canvas_layer := CanvasLayer.new()
	canvas_layer.layer = 10
	canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(canvas_layer)

	active_ui = lock_ui_scene.instantiate() as KeyBoxNumberLock
	canvas_layer.add_child(active_ui)
	active_ui.initialize_lock(saved_combination)

	active_ui.lock_closed.connect(_on_lock_closed.bind(canvas_layer))
	active_ui.lock_solved.connect(_on_lock_solved.bind(canvas_layer))


func _on_lock_closed(last_combination: Array[int], canvas_layer: CanvasLayer) -> void:
	saved_combination = last_combination
	active_ui = null
	canvas_layer.queue_free()

	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	keybox_minigame_ended.emit()


func _on_lock_solved(canvas_layer: CanvasLayer) -> void:
	is_unlocked = true
	active_ui = null
	canvas_layer.queue_free()

	if collision_shape:
		collision_shape.set_deferred("disabled", true)

	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if animation_player and animation_player.has_animation(open_animation_name):
		animation_player.play(open_animation_name)

	keybox_minigame_ended.emit()
