extends Control

@onready var text_label = $RichTextLabel
@onready var audio_player = $AudioStreamPlayer2D
@onready var fade_overlay = $FadeOverlay

var main_scene_path = "res://scenes/main/Main_Scene.tscn"
var text1_playtime = 7.5
var text2_playtime = 2.0
var last_visible_chars = 0
var fade_out_time = 2.5
var idle_time = 2.0

@export var text1 = "In more than 60 countries, members of the LGBTQIA+ community are criminalized and punished with imprisonment or the death penalty."
@export var text2 = "This could be one of their stories..."

func _ready():
	text_label.text = text1
	text_label.visible_ratio = 0.0
	fade_overlay.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_interval(idle_time)
	tween.tween_property(text_label, "visible_ratio", 1.0, text1_playtime)
	tween.tween_interval(idle_time)
	tween.tween_callback(change_to_text2)
	tween.tween_property(text_label, "visible_ratio", 1.0, text2_playtime)
	tween.tween_interval(idle_time)
	tween.tween_property(fade_overlay, "modulate:a", 1.0, fade_out_time)
	tween.tween_interval(idle_time)
	tween.tween_callback(start_game)

func _process(_delta):
	if text_label.visible_characters > last_visible_chars:
		last_visible_chars = text_label.visible_characters
		var aktueller_text = text_label.text
			
		if last_visible_chars > 0 and last_visible_chars <= aktueller_text.length():
			if aktueller_text[last_visible_chars - 1] != " ":
				audio_player.pitch_scale = randf_range(0.95, 1.05)
				audio_player.play()

func change_to_text2():
	text_label.text = text2
	text_label.visible_ratio = 0.0
	last_visible_chars = 0

func start_game():
	get_tree().change_scene_to_file(main_scene_path)
