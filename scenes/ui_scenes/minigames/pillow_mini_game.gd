extends Control

signal PillowMiniGameUiDeleted()

# sound during cutting
# maybe particle effects
# remove sharp object from inventory

@onready var success_player = $SuccessSoundPlayer
@onready var path_2d: Path2D = $CuttingLine
@onready var drawn_line:Line2D = $LineDisplayedDuringCut
@onready var instruct_label : Label = $Instructions
@onready var reset_label_timer : Timer = $Instructions/Timer
@onready var particles : GPUParticles2D = $LineDisplayedDuringCut/CutParticles

var is_tracking: bool = false
var total_samples: int = 0
var accumulated_score: float = 0.0
var minigame_ended = false

# Einstellungen für die Toleranz (in Pixeln)
@export var max_allowed_distance: float = 30.0  # Maximale Abweichung vom Pfad
@export var start_tolerance: float = 20.0       # Wie nah die Maus an Punkt A sein muss
@export var end_tolerance: float = 20.0         # Wie nah die Maus an Punkt B sein muss
@export var knife_icon:Texture2D
@export var win_percentage = 80

var path_length: float = 0.0

func _ready() -> void:
	path_length = path_2d.curve.get_baked_length()

func _process(_delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	if minigame_ended == true:
		queue_free()
	
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not is_tracking:
			var start_point = path_2d.curve.sample_baked(0.0) # Prüfen, ob der Spieler am Startpunkt (Offset 0.0) anfängt
			if mouse_pos.distance_to(start_point) <= start_tolerance:
				start_tracking()
			else:
				return # Ignorieren, wenn nicht am Start gedrückt wurde
		
		track_mouse_performance(mouse_pos)
	else:
		if is_tracking: # Wenn abgebrochen wurde, bevor das Ziel erreicht wurde
			cancel_tracking()
	

func start_tracking() -> void:
	is_tracking = true
	total_samples = 0
	accumulated_score = 0.0
	instruct_label.text = "stay on track"
	Input.set_custom_mouse_cursor(knife_icon)
	reset_label_timer.stop()
	reset_label_timer.wait_time = 3.0

func track_mouse_performance(mouse_pos: Vector2) -> void:
	drawn_line.add_point(mouse_pos)
	particles.visible=true
	particles.position = mouse_pos

	var closest_offset = path_2d.curve.get_closest_offset(mouse_pos)
	var closest_point = path_2d.curve.sample_baked(closest_offset)
	
	var distance = mouse_pos.distance_to(closest_point)
	var current_score = clamp(1.0 - (distance / max_allowed_distance), 0.0, 1.0)
	
	accumulated_score += current_score
	total_samples += 1
	
	# 2. Prüfen, ob der Endpunkt (B) erreicht wurde
	# Wir prüfen, ob der aktuelle Pfad-Offset nahe der Gesamtlänge ist UND die Maus nah am Endpunkt liegt
	var end_point = path_2d.curve.sample_baked(path_length)
	if closest_offset >= (path_length - end_tolerance) and mouse_pos.distance_to(end_point) <= end_tolerance:
		complete_tracking()

func complete_tracking() -> void:
	is_tracking = false
	var final_percentage = get_final_percentage()
	if final_percentage >= win_percentage:
		endMiniGame()
	else:
		instruct_label.text = "not accurate enough"
		drawn_line.clear_points()
		reset_label_timer.start()
		particles.visible= false
		Input.set_custom_mouse_cursor(null) #reset mouseicon

func cancel_tracking() -> void:
	is_tracking = false
	instruct_label.text = "cut from start to finish"
	drawn_line.clear_points()
	reset_label_timer.start()
	particles.visible= false
	Input.set_custom_mouse_cursor(null) #reset mouseicon

func get_final_percentage() -> float:
	if total_samples == 0:
		return 0.0
	return (accumulated_score / total_samples) * 100.0

func endMiniGame():
	Input.set_custom_mouse_cursor(null) #reset mouseicon
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	particles.visible= false
	instruct_label.text = "success"
	success_player.play()
	await success_player.finished

	PillowMiniGameUiDeleted.emit()
	minigame_ended=true

func _on_timer_timeout() -> void:
	instruct_label.text = "Cut it open"
