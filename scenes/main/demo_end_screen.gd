extends Control

@onready var text_label = $RichTextLabel
@onready var audio_player = $AudioStreamPlayer2D
@onready var fade_overlay = $FadeOverlay

var main_menu_path = "res://scenes/ui_scenes/main_menu.tscn"
var text1_playtime = 3.5
var text2_playtime = 1.5
var text3_playtime = 4.0
var text4_playtime = 2.2
var last_visible_chars = 0
var fade_out_time = 2.5
var idle_time = 2.0

@export var text1 = "This is the end of our playtest demo version."
@export var text2 = "Thanks for playing."
@export var text3 = "A game by Florian Wendel, Oskar Kotte and Sebastian Grewe."
@export var text4 = "Developed using Godot and Dialogic."

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
	tween.tween_callback(change_to_text3)
	tween.tween_property(text_label, "visible_ratio", 1.0, text2_playtime)
	tween.tween_interval(idle_time)
	tween.tween_callback(change_to_text4)
	tween.tween_property(text_label, "visible_ratio", 1.0, text2_playtime)
	tween.tween_interval(idle_time)
	tween.tween_property(fade_overlay, "modulate:a", 1.0, fade_out_time)
	tween.tween_interval(idle_time)
	tween.tween_callback(switch_to_main_menu)

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

func change_to_text3():
	text_label.text = text3
	text_label.visible_ratio = 0.0
	last_visible_chars = 0

func change_to_text4():
	text_label.text = text4
	text_label.visible_ratio = 0.0
	last_visible_chars = 0

func switch_to_main_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(main_menu_path)
