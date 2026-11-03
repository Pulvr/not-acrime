class_name KeyBoxNumberLock
extends Control

signal lock_solved
signal lock_closed(saved_combination: Array[int])

@export_group("Lock Settings")
@export var target_combination: Array[int] = [4, 6, 7, 1]
@export var digit_step_height: float = 92.0
@export var scroll_duration: float = 0.2

var current_combination: Array[int] = [0, 0, 0, 0]
var is_solved: bool = false
var _active_tweens: Array[Tween] = [null, null, null, null]

@onready var strips: Array[TextureRect] = [
	$LockContainer/DigitColumn1/SlotRect/SlotFrameRect/NumberStrip,
	$LockContainer/DigitColumn2/SlotRect/SlotFrameRect/NumberStrip,
	$LockContainer/DigitColumn3/SlotRect/SlotFrameRect/NumberStrip,
	$LockContainer/DigitColumn4/SlotRect/SlotFrameRect/NumberStrip
]

@onready var up_buttons: Array[BaseButton] = [
	$LockContainer/DigitColumn1/ButtonUp,
	$LockContainer/DigitColumn2/ButtonUp,
	$LockContainer/DigitColumn3/ButtonUp,
	$LockContainer/DigitColumn4/ButtonUp
]

@onready var down_buttons: Array[BaseButton] = [
	$LockContainer/DigitColumn1/ButtonDown,
	$LockContainer/DigitColumn2/ButtonDown,
	$LockContainer/DigitColumn3/ButtonDown,
	$LockContainer/DigitColumn4/ButtonDown
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_endless_strips()

	for i in range(4):
		up_buttons[i].pressed.connect(_on_arrow_pressed.bind(i, 1))
		down_buttons[i].pressed.connect(_on_arrow_pressed.bind(i, -1))
		_set_strip_immediately(i, current_combination[i])

	if has_node("CloseButton"):
		$CloseButton.pressed.connect(close_lock)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and not is_solved:
		get_viewport().set_input_as_handled()
		close_lock()


func initialize_lock(saved_state: Array[int]) -> void:
	current_combination = saved_state.duplicate()
	for i in range(4):
		_set_strip_immediately(i, current_combination[i])


func close_lock() -> void:
	if is_solved:
		return
	lock_closed.emit(current_combination)
	queue_free()


func _setup_endless_strips() -> void:
	for strip in strips:
		var buffer_clone := TextureRect.new()
		buffer_clone.texture = strip.texture
		buffer_clone.expand_mode = strip.expand_mode
		buffer_clone.stretch_mode = strip.stretch_mode
		buffer_clone.size = strip.size
		buffer_clone.position = Vector2(0.0, 10.0 * digit_step_height)
		strip.add_child(buffer_clone)


func _get_digit_y(digit: int) -> float:
	return -float(9 - digit) * digit_step_height


func _set_strip_immediately(column_index: int, digit: int) -> void:
	if _active_tweens[column_index] and _active_tweens[column_index].is_running():
		_active_tweens[column_index].kill()
	strips[column_index].position.y = _get_digit_y(digit)


func _on_arrow_pressed(column_index: int, direction: int) -> void:
	if is_solved:
		return

	var old_digit: int = current_combination[column_index]
	var new_digit: int = posmod(old_digit + direction, 10)
	current_combination[column_index] = new_digit

	_animate_strip(column_index, old_digit, new_digit, direction)
	_check_combination()


func _animate_strip(column_index: int, old_digit: int, new_digit: int, direction: int) -> void:
	var strip: TextureRect = strips[column_index]

	if _active_tweens[column_index] and _active_tweens[column_index].is_running():
		_active_tweens[column_index].kill()

	var start_y: float = _get_digit_y(old_digit)
	var target_y: float = _get_digit_y(new_digit)
	var wrap_to_top_after: bool = false

	if old_digit == 0 and direction == -1:
		start_y = _get_digit_y(0)
		target_y = -10.0 * digit_step_height
		wrap_to_top_after = true
	elif old_digit == 9 and direction == 1:
		start_y = -10.0 * digit_step_height
		target_y = _get_digit_y(0)

	strip.position.y = start_y

	var tween: Tween = create_tween()
	_active_tweens[column_index] = tween
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(strip, "position:y", target_y, scroll_duration)

	if wrap_to_top_after:
		tween.finished.connect(func() -> void: strip.position.y = _get_digit_y(9))


func _check_combination() -> void:
	if current_combination == target_combination:
		is_solved = true
		await get_tree().create_timer(0.35, true).timeout
		lock_solved.emit()
		queue_free()
