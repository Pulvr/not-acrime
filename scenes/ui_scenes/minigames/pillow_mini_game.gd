extends Node2D

@onready var cutting_line_progress = $"CuttingLine/FollowCuttingLine"
@onready var success_player = $SuccessSoundPlayer

signal PillowMiniGameUiDeleted()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not is_tracking:
			start_tracking()
		track_mouse_performance()
	else:
		if is_tracking:
			end_tracking()

	if cutting_line_progress.progress_ratio <= 1.0:
		cutting_line_progress.progress_ratio += 0.12*delta

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass
	# Maustaste gedrückt halten (if button pressed)
	# wenn gedrückt UND auf Path, Cursor shape wechseln zu Cursor.DRAG 
	# true wenn auf path
	# false wenn abgewichen


@onready var path_2d: Path2D = $CuttingLine

var is_tracking: bool = false
var total_samples: int = 0
var accumulated_score: float = 0.0
var max_allowed_distance: float = 50.0 # Maximale Abweichung in Pixeln, ab der die Wertung 0% beträgt

func start_tracking() -> void:
	is_tracking = true
	total_samples = 0
	accumulated_score = 0.0

func track_mouse_performance() -> void:
	var mouse_pos = get_local_mouse_position()
	
	# Findet den nächstgelegenen Punkt auf dem Pfad im Verhältnis zur Maus
	var closest_offset = path_2d.curve.get_closest_offset(mouse_pos)
	var closest_point = path_2d.curve.sample_baked(closest_offset)
	
	# Berechnet die Distanz zwischen Maus und Pfad
	var distance = mouse_pos.distance_to(closest_point)
	
	# Berechnet die Genauigkeit für diesen Frame (1.0 = perfekt auf dem Pfad, 0.0 = zu weit weg)
	var current_score = clamp(1.0 - (distance / max_allowed_distance), 0.0, 1.0)
	
	accumulated_score += current_score
	total_samples += 1

func end_tracking() -> void:
	is_tracking = false
	var final_percentage = get_final_percentage()
	print("Minispiel beendet. Genauigkeit: ", final_percentage, "%")

func get_final_percentage() -> float:
	if total_samples == 0:
		return 0.0
	return (accumulated_score / total_samples) * 100.0










func endMiniGame():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	success_player.play()
	await success_player.finished
	PillowMiniGameUiDeleted.emit()
	queue_free()
