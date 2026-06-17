extends Control

signal minigame_won
signal minigame_failed

# --- EINSTELLUNGEN ---
var center_pos := Vector2(0, 0)
var target_angle := 0.0 # 0 Grad in Radiant (Zeigt genau nach RECHTS)
var ring_color := Color(0.6, 0.6, 0.6) # Grau für intakte Ringe
var gap_color := Color(0.2, 0.8, 0.2, 0.5) # Halbtransparentes Grün für die Lücke
var default_font := preload("res://resources/fonts/Special_Elite/SpecialElite-Regular.ttf")
var current_visual_radius := 0.0 # Für die flüssige Animation des Schlüssels nach unten
var hint_anim_timer := 0.0
const HINT_ANIM_DURATION := 3.0 # Auf 3.0 Sekunden erhöht, um 1 Sekunde Pause einzubauen

# Hier definieren wir unsere Ringe von außen nach innen!
# radius = Entfernung vom Zentrum
# width = Dicke des Rings
# base_speed = Grund-Rotationsgeschwindigkeit (Radiant pro Sekunde, negativ = andere Richtung)
# gap_size = Wie groß ist die Lücke? (Radiant)
# rotation = Aktueller Winkel
var rings: Array[Dictionary] = []
var current_ring_index := 0 # 0 ist der äußerste Ring

func _ready() -> void:
	# Zentrum des Bildschirms berechnen
	center_pos = get_viewport_rect().size / 2.0
	
	# Wir initialisieren unsere 7 Ringe 
	# (Leicht abweichende Basis-Geschwindigkeiten und zufällige Startwinkel für mehr organische Dynamik)
	rings = [
		{"radius": 260.0, "width": 12.0, "base_speed": deg_to_rad(42.0), "gap_size": deg_to_rad(45.0), "rotation": randf() * TAU},
		{"radius": 230.0, "width": 12.0, "base_speed": deg_to_rad(-48.0), "gap_size": deg_to_rad(40.0), "rotation": randf() * TAU},
		{"radius": 200.0, "width": 12.0, "base_speed": deg_to_rad(38.0), "gap_size": deg_to_rad(35.0), "rotation": randf() * TAU},
		{"radius": 170.0, "width": 12.0, "base_speed": deg_to_rad(-55.0), "gap_size": deg_to_rad(35.0), "rotation": randf() * TAU},
		{"radius": 140.0, "width": 12.0, "base_speed": deg_to_rad(45.0), "gap_size": deg_to_rad(30.0), "rotation": randf() * TAU},
		{"radius": 110.0, "width": 12.0, "base_speed": deg_to_rad(-35.0), "gap_size": deg_to_rad(30.0), "rotation": randf() * TAU},
		{"radius": 80.0, "width": 12.0, "base_speed": deg_to_rad(52.0), "gap_size": deg_to_rad(25.0), "rotation": randf() * TAU}
	]
	
	# Startwert für die Animation setzen
	if rings.size() > 0:
		current_visual_radius = rings[0]["radius"]

func _process(delta: float) -> void:
	# Schwierigkeits-Multiplikator berechnen (steigt exponentiell an, je mehr Ringe geknackt wurden!)
	# Index 0: ~1x | Index 2: ~2.8x | Index 4: ~6.5x | Index 6: ~11.5x (deutlich aggressiver am Ende!)
	var speed_multiplier = 1.0 + (pow(float(current_ring_index), 1.6) * 0.6)
	
	# Rotiere alle noch vorhandenen Ringe
	for i in range(current_ring_index, rings.size()):
		var ring = rings[i]
		
		# Die aktuelle Geschwindigkeit ist die langsame Basisgeschwindigkeit multipliziert mit der "Wut" des Schlosses
		var current_speed = ring["base_speed"] * speed_multiplier
		ring["rotation"] += current_speed * delta
		
		# Verhindern, dass die Zahlen ins Unendliche wachsen (hält den Winkel zwischen 0 und TAU (360 Grad))
		ring["rotation"] = fposmod(ring["rotation"], TAU)
		
	# Hinweis-Animation Timer (nur beim ersten Ring updaten)
	if current_ring_index == 0:
		hint_anim_timer += delta
		if hint_anim_timer > HINT_ANIM_DURATION:
			hint_anim_timer -= HINT_ANIM_DURATION
		
	# Flüssige Bewegung des Schlüssels zum nächsten Ring
	var target_radius = 0.0
	if current_ring_index < rings.size():
		target_radius = rings[current_ring_index]["radius"]
	
	# lerp erzeugt eine weiche "Gleit"-Bewegung zum neuen Zielwert
	current_visual_radius = lerp(current_visual_radius, target_radius, delta * 8.0)
		
	# Sagt Godot, dass es die _draw() Funktion in diesem Frame neu ausführen soll
	queue_redraw()

# Dies ist eine eingebaute Godot-Funktion, um Formen per Code zu zeichnen!
func _draw() -> void:
	# --- SCHLÜSSELLOCH IN DER MITTE ZEICHNEN ---
	draw_keyhole()
	
	# Wir zeichnen nur die Ringe, die noch nicht geknackt wurden
	for i in range(current_ring_index, rings.size()):
		var ring = rings[i]
		
		# Die Lücke ist genau in der Mitte der aktuellen Rotation
		var half_gap = ring["gap_size"] / 2.0
		var solid_start = ring["rotation"] + half_gap
		var solid_end = ring["rotation"] + TAU - half_gap
		
		# 1. Den festen Ring zeichnen (ohne die Lücke)
		draw_arc(center_pos, ring["radius"], solid_start, solid_end, 64, ring_color, ring["width"], true)
		
		# 2. Die farbige "Passier-Zone" zeichnen (in der Lücke)
		var gap_start = ring["rotation"] - half_gap
		var gap_end = ring["rotation"] + half_gap
		
		# Wir machen die Lücken-Farbe beim AKTUELLEN (äußersten) Ring etwas heller/dicker zur Hervorhebung
		var current_gap_color = gap_color
		var current_width = ring["width"]
		if i == current_ring_index:
			current_gap_color = Color(0.3, 1.0, 0.3, 0.8) # Leuchtendes Grün
			current_width += 4.0 # Etwas dicker
			
		draw_arc(center_pos, ring["radius"], gap_start, gap_end, 16, current_gap_color, current_width, true)
		
	# --- SCHLÜSSEL UND PFEIL ZEICHNEN ---
	draw_key_and_arrow()

func draw_keyhole() -> void:
	var hole_color = Color(0.12, 0.12, 0.12) # Sehr dunkles Grau, fast Schwarz
	
	# Der obere runde Teil des Schlüssellochs
	draw_circle(center_pos + Vector2(0, -8), 20.0, hole_color)
	
	# Der untere eckige Teil (Trapez)
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
	
	# Animation nur für den allerersten Ring (Index 0) berechnen
	if current_ring_index == 0:
		if hint_anim_timer < 1.0:
			# Erste Sekunde: Alles verharrt in der Ausgangsposition
			arrow_alpha = 1.0
			key_anim_offset = 0.0
		else:
			# Ab Sekunde 1: Die weiche Animation beginnt
			var anim_time = hint_anim_timer - 1.0 # läuft von 0.0 bis 2.0
			
			# Pfeil verblasst weich
			arrow_alpha = 1.0 - smoothstep(0.0, 0.6, anim_time)
			
			# Schlüssel bewegt sich nach links und verharrt dann
			if anim_time < 0.8:
				key_anim_offset = smoothstep(0.0, 0.8, anim_time) * -45.0
			else:
				key_anim_offset = -45.0

	# Dynamischer Abstand basierend auf dem aktuellen Ring-Radius
	# Erhöht von 40.0 auf 70.0, damit Pfeil und Schlüssel weiter außen liegen
	var base_x = current_visual_radius + 70.0
	
	# --- PFEIL ZEICHNEN ---
	var arrow_pos = center_pos + Vector2(base_x, 0)
	
	var current_arrow_color = Color(0.8, 0.8, 0.8, arrow_alpha * 0.5) 
	var outline_color = Color(1.0, 1.0, 1.0, arrow_alpha)
	var text_color = Color(0.0, 0.0, 0.0, arrow_alpha)
	
	# Die Punkte für die nach LINKS zeigende Pfeilform
	var arrow_points = PackedVector2Array([
		arrow_pos + Vector2(20, -15), # Oben Rechts
		arrow_pos + Vector2(20, 15),  # Unten Rechts
		arrow_pos + Vector2(-5, 15),  # Unten (vor der Spitze)
		arrow_pos + Vector2(-5, 25),  # Äußere Spitze Unten
		arrow_pos + Vector2(-30, 0),  # Die eigentliche Spitze links (zeigt auf den Ring)
		arrow_pos + Vector2(-5, -25), # Äußere Spitze Oben
		arrow_pos + Vector2(-5, -15)  # Oben (vor der Spitze)
	])
	
	# Pfeil nur zeichnen, wenn er durch die Animation sichtbar sein soll
	if arrow_alpha > 0.0:
		draw_colored_polygon(arrow_points, current_arrow_color)
		var outline_points = arrow_points.duplicate()
		outline_points.append(arrow_points[0])
		draw_polyline(outline_points, outline_color, 2.0)
		# Das "A" in den Pfeil schreiben
		draw_string(default_font, arrow_pos + Vector2(-4, 6), "A", HORIZONTAL_ALIGNMENT_CENTER, -1, 22, text_color)

	# --- SCHLÜSSEL ZEICHNEN ---
	# Immer in einem festen Abstand + die Animations-Verschiebung
	var key_pos = center_pos + Vector2(base_x + 85.0 + key_anim_offset, 0)
	
	# Schlüssel-Griff (Kopf, rechts)
	draw_rect(Rect2(key_pos.x + 10, key_pos.y - 15, 24, 30), ring_color, false, 4.0)
	# Schlüssel-Schaft (horizontal)
	draw_rect(Rect2(key_pos.x - 30, key_pos.y - 4, 40, 8), ring_color)
	# Schlüssel-Bart (Die Zähne, links unten)
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
		return # Spiel ist schon vorbei
		
	var active_ring = rings[current_ring_index]
	var ring_rot = active_ring["rotation"]
	var half_gap = active_ring["gap_size"] / 2.0
	
	# Wir berechnen die kürzeste Distanz zwischen dem Ziel (Oben, -90 Grad) und der Mitte der Lücke
	var diff = fposmod(target_angle - ring_rot + PI, TAU) - PI
	
	# Ist die Distanz kleiner als die halbe Lücke? -> GETROFFEN!
	if abs(diff) <= half_gap:
		success_hit()
	else:
		fail_game()

func success_hit() -> void:
	print("Ring " + str(current_ring_index) + " geknackt!")
	
	# Hier könntest du einen AudioStreamPlayer für ein "Klick/Zerbrech"-Geräusch abspielen
	# $SuccessSound.play()
	
	current_ring_index += 1 # Zum nächsten (inneren) Ring wechseln
	
	if current_ring_index >= rings.size():
		print("SCHLOSS GEÖFFNET!")
		minigame_won.emit()
		queue_free() # Minispiel beenden

func fail_game() -> void:
	print("Falsches Timing! Zurück auf Anfang.")
	
	# Hier könntest du einen Fehler-Sound abspielen
	# $FailSound.play()
	
	# Spiel sofort neustarten
	current_ring_index = 0
	current_visual_radius = rings[0]["radius"] # Setzt auch den Pfeil visuell hart wieder nach ganz außen zurück
	hint_anim_timer = 0.0 # Startet die Erklärungs-Animation wieder von vorne
	
	# (Optional: Dem Spieler mitteilen, dass er verloren hat, oder das Fenster schließen)
	# minigame_failed.emit()
	# queue_free()
