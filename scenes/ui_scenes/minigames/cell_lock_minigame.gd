extends Control

signal minigame_won
signal minigame_failed

@export_category("Settings")

@export_group("Difficulty")
##Initial speed value for rings [Deg/s]. Real values differ up to 20% from this value.
@export var base_start_speed := 45.0
##The higher the factor, the faster the rings will get.
@export var difficulty_factor := 0.6
##The exponent influences the raise of speed. 1.0 is linear, > 1.0 is exponential. If the value is higher, the inner rings will be faster.
@export var difficulty_exponent := 1.6
##Size of each ring's gap [deg]. From outer to inner ring.
@export var ring_gap_sizes: Array[float] = [45.0, 40.0, 35.0, 35.0, 30.0, 30.0, 25.0]

@export_group("Design")
##Do not change unless you know what you are doing!
@export var center_pos := Vector2(0, 0)
##Changes the angle from where the key is inserted. 0.0 is the right side.
@export var input_angle := 0.0
##Color of the rings (impenetrable).
@export var ring_color := Color(0.6, 0.6, 0.6)
##Color of the ring gap (penetrable).
@export var gap_color := Color(0.2, 0.8, 0.2, 0.5)

#Audio
##Sound played with every broken ring.
@onready var ring_broken_sound = $RingBrokenSoundPlayer
##Sound played when last ring broken.
@onready var lock_opened_sound = $LockOpenedSoundPlayer
##Sound played when hitting the impenetrable zone of a ring (+ reset).
@onready var fail_sound = $FailSoundPlayer

@onready var player = get_tree().get_first_node_in_group("player")

@export_group("Other")
##Modifies the duration of the tutorial hint.
@export var hint_animation_duration := 3.0
@export var default_font := preload("res://resources/fonts/Special_Elite/SpecialElite-Regular.ttf")
@export var input_key_displayed = "A"
var current_visual_radius := 0.0
var hint_anim_timer := 0.0

var rings: Array[Dictionary] = []
var current_ring_index := 0


var is_animation_running: bool = false
var is_won: bool = false
var door_tween: Tween

func _ready() -> void:
	center_pos = get_viewport_rect().size / 2.0
	
	rings = [
		{"radius": 260.0, "width": 12.0, "base_speed": deg_to_rad(base_start_speed * randf_range(0.8, 1.2)), "gap_size": _get_gap_size(0), "rotation": randf() * TAU},
		{"radius": 230.0, "width": 12.0, "base_speed": deg_to_rad(-base_start_speed * randf_range(0.8, 1.2)), "gap_size": _get_gap_size(1), "rotation": randf() * TAU},
		{"radius": 200.0, "width": 12.0, "base_speed": deg_to_rad(base_start_speed * randf_range(0.8, 1.2)), "gap_size": _get_gap_size(2), "rotation": randf() * TAU},
		{"radius": 170.0, "width": 12.0, "base_speed": deg_to_rad(-base_start_speed * randf_range(0.8, 1.2)), "gap_size": _get_gap_size(3), "rotation": randf() * TAU},
		{"radius": 140.0, "width": 12.0, "base_speed": deg_to_rad(base_start_speed * randf_range(0.8, 1.2)), "gap_size": _get_gap_size(4), "rotation": randf() * TAU},
		{"radius": 110.0, "width": 12.0, "base_speed": deg_to_rad(-base_start_speed * randf_range(0.8, 1.2)), "gap_size": _get_gap_size(5), "rotation": randf() * TAU},
		{"radius": 80.0, "width": 12.0, "base_speed": deg_to_rad(base_start_speed * randf_range(0.8, 1.2)), "gap_size": _get_gap_size(6), "rotation": randf() * TAU}
	]
	
	if rings.size() > 0:
		current_visual_radius = rings[0]["radius"]

func _get_gap_size(index: int) -> float:
	if index < ring_gap_sizes.size():
		return deg_to_rad(ring_gap_sizes[index])
	return deg_to_rad(30.0)

func _process(delta: float) -> void:
	var speed_multiplier = 1.0 + (pow(float(current_ring_index), difficulty_exponent) * difficulty_factor)
	for i in range(current_ring_index, rings.size()):
		var ring = rings[i]
		var current_speed = ring["base_speed"] * speed_multiplier
		ring["rotation"] += current_speed * delta
		
		ring["rotation"] = fposmod(ring["rotation"], TAU)
		
	if current_ring_index == 0:
		hint_anim_timer += delta
		if hint_anim_timer > hint_animation_duration:
			hint_anim_timer -= hint_animation_duration
		
	var target_radius = 0.0
	if current_ring_index < rings.size():
		target_radius = rings[current_ring_index]["radius"]
	
	current_visual_radius = lerp(current_visual_radius, target_radius, delta * 8.0)
		
	queue_redraw()

func _draw() -> void:
	if not is_won:
		draw_keyhole()
	
	for i in range(current_ring_index, rings.size()):
		var ring = rings[i]
		
		var half_gap = ring["gap_size"] / 2.0
		var solid_start = ring["rotation"] + half_gap
		var solid_end = ring["rotation"] + TAU - half_gap
		
		draw_arc(center_pos, ring["radius"], solid_start, solid_end, 64, ring_color, ring["width"], true)
		
		var gap_start = ring["rotation"] - half_gap
		var gap_end = ring["rotation"] + half_gap
		
		var current_gap_color = gap_color
		var current_width = ring["width"]
		if i == current_ring_index:
			current_gap_color = Color(0.3, 1.0, 0.3, 0.8)
			current_width += 4.0
			
		draw_arc(center_pos, ring["radius"], gap_start, gap_end, 16, current_gap_color, current_width, true)
		
	draw_key_and_arrow()

func draw_keyhole() -> void:
	var hole_color = Color(0.12, 0.12, 0.12)
	
	draw_circle(center_pos + Vector2(0, -8), 20.0, hole_color)
	
	var hole_points = PackedVector2Array([
		center_pos + Vector2(-12, 0),
		center_pos + Vector2(12, 0),
		center_pos + Vector2(20, 35),
		center_pos + Vector2(-20, 35)
	])
	draw_colored_polygon(hole_points, hole_color)

func draw_key_and_arrow() -> void:
	var arrow_alpha = 0.0
	var key_anim_offset = -45.0
	
	if current_ring_index == 0:
		if hint_anim_timer < 1.0:
			arrow_alpha = 1.0
			key_anim_offset = 0.0
		else:
			var anim_time = hint_anim_timer - 1.0
			
			arrow_alpha = 1.0 - smoothstep(0.0, 0.6, anim_time)
			
			if anim_time < 0.8:
				key_anim_offset = smoothstep(0.0, 0.8, anim_time) * -45.0
			else:
				key_anim_offset = -45.0

	var base_x = current_visual_radius + 70.0
	
	var arrow_pos = center_pos + Vector2(base_x, 0)
	
	var current_arrow_color = Color(0.8, 0.8, 0.8, arrow_alpha * 0.5) 
	var outline_color = Color(1.0, 1.0, 1.0, arrow_alpha)
	var text_color = Color(0.0, 0.0, 0.0, arrow_alpha)
	
	var arrow_points = PackedVector2Array([
		arrow_pos + Vector2(20, -15),
		arrow_pos + Vector2(20, 15),
		arrow_pos + Vector2(-5, 15), 
		arrow_pos + Vector2(-5, 25),
		arrow_pos + Vector2(-30, 0),
		arrow_pos + Vector2(-5, -25),
		arrow_pos + Vector2(-5, -15)
	])
	
	if arrow_alpha > 0.0:
		draw_colored_polygon(arrow_points, current_arrow_color)
		var outline_points = arrow_points.duplicate()
		outline_points.append(arrow_points[0])
		draw_polyline(outline_points, outline_color, 2.0)
		draw_string(default_font, arrow_pos + Vector2(-4, 6), input_key_displayed, HORIZONTAL_ALIGNMENT_CENTER, -1, 22, text_color)

	var key_pos = center_pos + Vector2(base_x + 85.0 + key_anim_offset, 0)
	
	draw_rect(Rect2(key_pos.x + 10, key_pos.y - 15, 24, 30), ring_color, false, 4.0)
	draw_rect(Rect2(key_pos.x - 30, key_pos.y - 4, 40, 8), ring_color)
	draw_rect(Rect2(key_pos.x - 20, key_pos.y + 4, 8, 14), ring_color)
	draw_rect(Rect2(key_pos.x - 8, key_pos.y + 4, 8, 8), ring_color)

func _input(event: InputEvent) -> void:
	var is_a_key = event is InputEventKey and event.keycode == KEY_A and event.pressed and not event.echo
	var is_lmb = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	
	if is_a_key or is_lmb:
		check_hit()
	
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		minigame_failed.emit()
		queue_free()
		return

func check_hit() -> void:
	if current_ring_index >= rings.size():
		return
		
	var active_ring = rings[current_ring_index]
	var ring_rot = active_ring["rotation"]
	var half_gap = active_ring["gap_size"] / 2.0
	
	var diff = fposmod(deg_to_rad(input_angle) - ring_rot + PI, TAU) - PI
	
	if abs(diff) <= half_gap:
		success_hit()
	else:
		fail_game()

func success_hit() -> void:
	
	ring_broken_sound.play()
	
	current_ring_index += 1
	
	if current_ring_index >= rings.size():
		#print("SCHLOSS GEÖFFNET!")
		is_won = true
		if lock_opened_sound:
			player.can_move = false
			lock_opened_sound.play()
			await get_tree().create_timer(1.85).timeout
			_animate_door(deg_to_rad(-50), 3.4 - 1.85)
			await lock_opened_sound.finished
		minigame_won.emit()
		queue_free()

func fail_game() -> void:
	
	fail_sound.play()
	
	current_ring_index = 0
	current_visual_radius = rings[0]["radius"]
	hint_anim_timer = 0.0
	
	# (Optional: Dem Spieler mitteilen, dass er verloren hat, oder das Fenster schließen)
	# minigame_failed.emit()
	# queue_free()

func _animate_door(target_rot_y: float, duration: float):
	is_animation_running = true
	player.hint_checker = !player.hint_checker
	player.interact_hint.visible = !player.interact_hint.visible
	if door_tween:
		door_tween.kill()

	var cell_door = get_tree().get_first_node_in_group("door")
	door_tween = create_tween()
	door_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	door_tween.tween_property(cell_door, "rotation:y", target_rot_y, duration)
	door_tween.finished.connect(_on_tween_completed.bind(), CONNECT_ONE_SHOT)
	
func _on_tween_completed():
	var cell_door = get_tree().get_first_node_in_group("door")
	cell_door.get_parent().get_node("CollisionShape3D").rotation.y -= cell_door.rotation.y
	cell_door.get_parent().get_node("CollisionShape3D").position = Vector3(-2.05, 2, -0.8)
	is_animation_running = false
	player.can_move = true
