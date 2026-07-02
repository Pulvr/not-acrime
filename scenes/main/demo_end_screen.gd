extends Control

@onready var text_label = $RichTextLabel
@onready var audio_player = $AudioStreamPlayer2D
@onready var fade_overlay = $FadeOverlay

var main_menu_path = "res://scenes/ui_scenes/main_menu.tscn"
var text1_playtime = 3.5
var text2_playtime = 1.5
var text3_playtime = 4.0
var text4_playtime = 2.2
var text5_playtime = 3
var text6_playtime = 3
var text7_playtime = 3
var text8_playtime = 3
var text9_playtime = 3
var text10_playtime = 3
var text11_playtime = 3
var text12_playtime = 3
var last_visible_chars = 0
var fade_out_time = 2.5
var idle_time = 2.0

@export var text1 = "There are still countries imposing the death penalty upon homosexuality.."
@export var text2 = "Did you read the newspaper headlines on the wall?"
@export var text3 = "Those were all real."
@export var text4 = "Criminilization of LGBTIQ is rising still."
@export var text5 = "Stand together."
@export var text6 = "Personality Rights are Human Rights."
@export var text7 = "..."
@export var text8 = "Thank you for playing!"
@export var text9 = "This is the end of our playtest demo..."
@export var text10 = "...made by Florian Wendel, Sebastian Grewe and Oskar Kotte."
@export var text11 = "Proudly developed using Godot 4 and Dialogic 2."
@export var text12 = "Sources: 	source1 \n
							    source2 \n
							    source3"

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
	tween.tween_property(text_label, "visible_ratio", 1.0, text3_playtime)
	tween.tween_interval(idle_time)
	tween.tween_callback(change_to_text4)
	tween.tween_property(text_label, "visible_ratio", 1.0, text4_playtime)
	tween.tween_interval(idle_time)
	tween.tween_callback(change_to_text5)
	tween.tween_property(text_label, "visible_ratio", 1.0, text5_playtime)
	tween.tween_interval(idle_time)
	tween.tween_callback(change_to_text6)
	tween.tween_property(text_label, "visible_ratio", 1.0, text6_playtime)
	tween.tween_interval(idle_time)
	tween.tween_callback(change_to_text7)
	tween.tween_property(text_label, "visible_ratio", 1.0, text7_playtime)
	tween.tween_interval(idle_time)
	tween.tween_callback(change_to_text8)
	tween.tween_property(text_label, "visible_ratio", 1.0, text8_playtime)
	tween.tween_interval(idle_time)
	tween.tween_callback(change_to_text9)
	tween.tween_property(text_label, "visible_ratio", 1.0, text9_playtime)
	tween.tween_interval(idle_time)
	tween.tween_callback(change_to_text10)
	tween.tween_property(text_label, "visible_ratio", 1.0, text10_playtime)
	tween.tween_interval(idle_time)
	tween.tween_callback(change_to_text11)
	tween.tween_property(text_label, "visible_ratio", 1.0, text11_playtime)
	tween.tween_interval(idle_time)
	tween.tween_callback(change_to_text12)
	tween.tween_property(text_label, "visible_ratio", 1.0, text12_playtime)
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

func _input(event):
	var is_skip_button = event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)
	
	if is_skip_button:
		switch_to_main_menu()

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

func change_to_text5():
	text_label.text = text5
	text_label.visible_ratio = 0.0
	last_visible_chars = 0
	
func change_to_text6():
	text_label.text = text6
	text_label.visible_ratio = 0.0
	last_visible_chars = 0

func change_to_text7():
	text_label.text = text7
	text_label.visible_ratio = 0.0
	last_visible_chars = 0

func change_to_text8():
	text_label.text = text8
	text_label.visible_ratio = 0.0
	last_visible_chars = 0
	
func change_to_text9():
	text_label.text = text9
	text_label.visible_ratio = 0.0
	last_visible_chars = 0
	
func change_to_text10():
	text_label.text = text10
	text_label.visible_ratio = 0.0
	last_visible_chars = 0
	
func change_to_text11():
	text_label.text = text11
	text_label.visible_ratio = 0.0
	last_visible_chars = 0
	
func change_to_text12():
	text_label.text = text12
	text_label.visible_ratio = 0.0
	last_visible_chars = 0
	
func switch_to_main_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(main_menu_path)
