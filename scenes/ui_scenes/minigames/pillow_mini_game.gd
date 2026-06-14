extends Control

signal PillowMiniGameUiDeleted()

@onready var cutting_line_progress = $"CuttingLine/FollowCuttingLine"
@onready var success_player = $SuccessSoundPlayer
@onready var path_2d: Path2D = $CuttingLine
@onready var instruct_label : Label = $Instructions
@onready var reset_label_timer : Timer = $Instructions/Timer

var is_tracking: bool = false
var total_samples: int = 0
var accumulated_score: float = 0.0

# Einstellungen für die Toleranz (in Pixeln)
@export var max_allowed_distance: float = 30.0  # Maximale Abweichung vom Pfad
@export var start_tolerance: float = 20.0       # Wie nah die Maus an Punkt A sein muss
@export var end_tolerance: float = 20.0         # Wie nah die Maus an Punkt B sein muss

var path_length: float = 0.0

func _ready() -> void:
	path_length = path_2d.curve.get_baked_length()

func _process(delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
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

	cutting_line_progress.progress_ratio += 0.2 * delta # Anzeiger für CuttingLine


	


func start_tracking() -> void:
	is_tracking = true
	total_samples = 0
	accumulated_score = 0.0
	instruct_label.text = "stay on track"
	reset_label_timer.stop()
	reset_label_timer.wait_time = 3.0

func track_mouse_performance(mouse_pos: Vector2) -> void:
	var closest_offset = path_2d.curve.get_closest_offset(mouse_pos)
	var closest_point = path_2d.curve.sample_baked(closest_offset)
	
	# 1. Distanz und Score berechnen
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
	print("Ziel erreicht! Erfolgreich beendet. Genauigkeit: ", final_percentage, "%")
	if final_percentage >= 80.0:
		endMiniGame()
	else:
		instruct_label.text = "not accurate enough"
		reset_label_timer.start()

func cancel_tracking() -> void:
	is_tracking = false
	instruct_label.text = "cut from start to finish"
	reset_label_timer.start()

func get_final_percentage() -> float:
	if total_samples == 0:
		return 0.0
	return (accumulated_score / total_samples) * 100.0

func endMiniGame():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	instruct_label.text = "congrats"
	success_player.play()
	await success_player.finished
	PillowMiniGameUiDeleted.emit()
	queue_free()

func _on_timer_timeout() -> void:
	instruct_label.text = "Cut it open"
