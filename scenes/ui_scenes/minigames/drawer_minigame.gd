class_name SymbolPuzzleMinigame
extends CanvasLayer

signal puzzle_solved
signal puzzle_cancelled

enum Symbol { NONE, TRIANGLE, CIRCLE, SQUARE, STAR }

const TARGET_SOLUTION: Array[Symbol] = [
	Symbol.SQUARE,
	Symbol.TRIANGLE,
	Symbol.TRIANGLE,
	Symbol.TRIANGLE,
	Symbol.CIRCLE,
	Symbol.STAR,
	Symbol.SQUARE,
	Symbol.STAR,
	Symbol.CIRCLE
]

const FIXED_INDICES: Array[int] = [2, 4]

const INITIAL_INVENTORY: Array[Symbol] = [
	Symbol.TRIANGLE,
	Symbol.TRIANGLE,
	Symbol.STAR,
	Symbol.STAR,
	Symbol.SQUARE,
	Symbol.SQUARE,
	Symbol.CIRCLE
]

const DIN_A4_PORTRAIT_RATIO: float = 1.41421356

@export_group("Assets (Optional - nutzt Platzhalter wenn leer)")
@export var slot_background_texture: Texture2D
@export var fixed_slot_background_texture: Texture2D
@export var item_background_texture: Texture2D
@export var note_paper_texture: Texture2D

@export var triangle_texture: Texture2D
@export var circle_texture: Texture2D
@export var square_texture: Texture2D
@export var star_texture: Texture2D

@export_group("Layout & Größen")
@export var slot_size: Vector2 = Vector2(96, 96)
@export var inventory_item_size: Vector2 = Vector2(84, 84)
@export var note_width: float = 460.0
@export var note_peek_height: float = 48.0
@export var note_tween_duration: float = 0.28

@export_group("Platzhalter-Farben")
@export var slot_color: Color = Color(0.22, 0.22, 0.25, 1.0)
@export var fixed_slot_color: Color = Color(0.14, 0.14, 0.16, 1.0)
@export var item_color: Color = Color(0.32, 0.32, 0.38, 1.0)
@export var note_color: Color = Color(0.96, 0.95, 0.92, 1.0)

var _board_state: Array[Symbol] = []
var _inventory_items: Array[Symbol] = []
var _slot_nodes: Array[Control] = []
var _inventory_nodes: Array[Control] = []

var _held_symbol: Symbol = Symbol.NONE
var _is_note_open: bool = false
var _is_closing: bool = false
var _previous_mouse_mode: Input.MouseMode = Input.MOUSE_MODE_CAPTURED
var _note_tween: Tween = null

@onready var slots_container: HBoxContainer = $RootUI/BoardCenter/SlotsContainer
@onready var inventory_container: HBoxContainer = $RootUI/BottomBar/InventoryContainer
@onready var note_sheet: PanelContainer = $RootUI/NoteSheet
@onready var note_texture_rect: TextureRect = $RootUI/NoteSheet/NoteTexture
@onready var note_label: Label = $RootUI/NoteSheet/NoteText
@onready var drag_preview: PanelContainer = $RootUI/DragPreview
@onready var preview_texture_rect: TextureRect = $RootUI/DragPreview/PreviewTexture
@onready var preview_label: Label = $RootUI/DragPreview/PreviewLabel


func _ready() -> void:
	get_tree().paused = true

	_previous_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	_init_puzzle_state()
	_setup_note_sheet()
	_setup_drag_preview()
	_rebuild_slots_ui()
	_rebuild_inventory_ui()


func _process(_delta: float) -> void:
	if _held_symbol != Symbol.NONE and drag_preview.visible:
		drag_preview.global_position = (
			get_viewport().get_mouse_position() - (drag_preview.size * 0.5)
		)


func _input(event: InputEvent) -> void:
	if _is_closing:
		return

	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_cancel_minigame()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		get_viewport().set_input_as_handled()
		_handle_left_click(event.position)


func _init_puzzle_state() -> void:
	_board_state.resize(TARGET_SOLUTION.size())
	for i in range(TARGET_SOLUTION.size()):
		if i in FIXED_INDICES:
			_board_state[i] = TARGET_SOLUTION[i]
		else:
			_board_state[i] = Symbol.NONE

	_inventory_items = INITIAL_INVENTORY.duplicate()


func _setup_note_sheet() -> void:
	var note_height: float = note_width * DIN_A4_PORTRAIT_RATIO
	note_sheet.custom_minimum_size = Vector2(note_width, note_height)
	note_sheet.size = Vector2(note_width, note_height)

	var style := StyleBoxFlat.new()
	style.bg_color = Color.WHITE if note_paper_texture else note_color
	style.set_content_margin_all(28)
	note_sheet.add_theme_stylebox_override("panel", style)

	if note_paper_texture:
		note_texture_rect.texture = note_paper_texture
		note_texture_rect.visible = true
	else:
		note_texture_rect.visible = false

	note_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	note_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note_label.text = (
		"HINWEISE ZUM SCHLOSS\n\n"
		+ "1. Alle Dreiecke (▲) hängen als eine einzige, ununterbrochene Gruppe zusammen. "
		+ "Kein anderes Symbol darf direkt neben seinem gleichen Symbol liegen.\n\n"
		+ "2. Jeder Stern (★) steht direkt zwischen einem Kreis (●) und einem Viereck (■).\n\n"
		+ "3. Kreise (●) und Vierecke (■) dürfen sich niemals direkt berühren.\n\n\n"
		+ "[ Klicken zum Lesen / Wegklicken ]"
	)

	var viewport_width: float = get_viewport().get_visible_rect().size.x
	note_sheet.position = Vector2(
		(viewport_width - note_width) * 0.5, -note_height + note_peek_height
	)


func _setup_drag_preview() -> void:
	drag_preview.custom_minimum_size = inventory_item_size
	drag_preview.size = inventory_item_size
	drag_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_update_drag_preview()


func _rebuild_slots_ui() -> void:
	for child in slots_container.get_children():
		child.queue_free()
	_slot_nodes.clear()

	for i in range(_board_state.size()):
		var is_fixed: bool = i in FIXED_INDICES
		var bg_tex: Texture2D = (
			fixed_slot_background_texture if is_fixed else slot_background_texture
		)
		var bg_col: Color = fixed_slot_color if is_fixed else slot_color

		var slot_panel := _create_symbol_box(_board_state[i], slot_size, bg_col, bg_tex, is_fixed)
		slots_container.add_child(slot_panel)
		_slot_nodes.append(slot_panel)


func _rebuild_inventory_ui() -> void:
	for child in inventory_container.get_children():
		child.queue_free()
	_inventory_nodes.clear()

	for sym in _inventory_items:
		var item_panel := _create_symbol_box(
			sym, inventory_item_size, item_color, item_background_texture, false
		)
		inventory_container.add_child(item_panel)
		_inventory_nodes.append(item_panel)


func _create_symbol_box(
	sym: Symbol, box_size: Vector2, bg_color: Color, bg_tex: Texture2D, is_fixed: bool
) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = box_size
	panel.mouse_filter = Control.MOUSE_FILTER_PASS

	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.45, 0.45, 0.5) if not is_fixed else Color(0.85, 0.7, 0.3)
	panel.add_theme_stylebox_override("panel", style)

	if bg_tex:
		var bg_rect := TextureRect.new()
		bg_rect.texture = bg_tex
		bg_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		panel.add_child(bg_rect)

	var sym_tex: Texture2D = _get_symbol_texture(sym)
	if sym_tex:
		var icon := TextureRect.new()
		icon.texture = sym_tex
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		panel.add_child(icon)
	else:
		var lbl := Label.new()
		lbl.text = _get_symbol_string(sym)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 36)
		if is_fixed:
			lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
		panel.add_child(lbl)

	return panel


func _update_drag_preview() -> void:
	if _held_symbol == Symbol.NONE:
		drag_preview.visible = false
		return

	drag_preview.visible = true
	drag_preview.global_position = get_viewport().get_mouse_position() - (drag_preview.size * 0.5)

	var style := StyleBoxFlat.new()
	style.bg_color = item_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color.WHITE
	drag_preview.add_theme_stylebox_override("panel", style)

	var sym_tex: Texture2D = _get_symbol_texture(_held_symbol)
	if sym_tex:
		preview_texture_rect.texture = sym_tex
		preview_texture_rect.visible = true
		preview_label.visible = false
	else:
		preview_texture_rect.visible = false
		preview_label.visible = true
		preview_label.text = _get_symbol_string(_held_symbol)
		preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		preview_label.add_theme_font_size_override("font_size", 36)


func _handle_left_click(mouse_pos: Vector2) -> void:
	if _is_note_open:
		if not note_sheet.get_global_rect().has_point(mouse_pos):
			_animate_note(false)
		return

	if note_sheet.get_global_rect().has_point(mouse_pos):
		_animate_note(true)
		return

	if _held_symbol != Symbol.NONE:
		var clicked_slot_idx: int = _get_slot_index_at(mouse_pos)

		if clicked_slot_idx != -1:
			if clicked_slot_idx in FIXED_INDICES:
				return

			var previous_symbol: Symbol = _board_state[clicked_slot_idx]
			_board_state[clicked_slot_idx] = _held_symbol
			_held_symbol = previous_symbol

			_rebuild_slots_ui()
			_update_drag_preview()
			_check_win_condition()
			return

		_inventory_items.append(_held_symbol)
		_held_symbol = Symbol.NONE
		_rebuild_inventory_ui()
		_update_drag_preview()
		return

	var clicked_inv_idx: int = _get_inventory_index_at(mouse_pos)
	if clicked_inv_idx != -1:
		_held_symbol = _inventory_items[clicked_inv_idx]
		_inventory_items.remove_at(clicked_inv_idx)
		_rebuild_inventory_ui()
		_update_drag_preview()
		return

	var slot_idx: int = _get_slot_index_at(mouse_pos)
	if slot_idx != -1 and not (slot_idx in FIXED_INDICES) and _board_state[slot_idx] != Symbol.NONE:
		_held_symbol = _board_state[slot_idx]
		_board_state[slot_idx] = Symbol.NONE
		_rebuild_slots_ui()
		_update_drag_preview()


func _get_slot_index_at(mouse_pos: Vector2) -> int:
	for i in range(_slot_nodes.size()):
		if _slot_nodes[i].get_global_rect().has_point(mouse_pos):
			return i
	return -1


func _get_inventory_index_at(mouse_pos: Vector2) -> int:
	for i in range(_inventory_nodes.size()):
		if _inventory_nodes[i].get_global_rect().has_point(mouse_pos):
			return i
	return -1


func _animate_note(open: bool) -> void:
	_is_note_open = open
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var note_height: float = note_sheet.size.y

	var target_y: float
	if open:
		target_y = (viewport_size.y - note_height) * 0.5
	else:
		target_y = -note_height + note_peek_height

	if _note_tween and _note_tween.is_running():
		_note_tween.kill()

	_note_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_note_tween.tween_property(note_sheet, "position:y", target_y, note_tween_duration)


func _check_win_condition() -> void:
	for i in range(TARGET_SOLUTION.size()):
		if _board_state[i] != TARGET_SOLUTION[i]:
			return

	_is_closing = true
	Input.mouse_mode = _previous_mouse_mode
	get_tree().paused = false
	puzzle_solved.emit()
	queue_free()


func _cancel_minigame() -> void:
	_is_closing = true
	Input.mouse_mode = _previous_mouse_mode
	get_tree().paused = false
	puzzle_cancelled.emit()
	queue_free()


func _get_symbol_texture(sym: Symbol) -> Texture2D:
	match sym:
		Symbol.TRIANGLE:
			return triangle_texture
		Symbol.CIRCLE:
			return circle_texture
		Symbol.SQUARE:
			return square_texture
		Symbol.STAR:
			return star_texture
		_:
			return null


func _get_symbol_string(sym: Symbol) -> String:
	match sym:
		Symbol.TRIANGLE:
			return "▲"
		Symbol.CIRCLE:
			return "●"
		Symbol.SQUARE:
			return "■"
		Symbol.STAR:
			return "★"
		_:
			return ""
