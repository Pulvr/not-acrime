extends Control

@onready var text_label = $TextLabel
@onready var prompt_label = $PromptLabel
@onready var audio_player = $AudioStreamPlayer2D
@onready var fade_overlay = $FadeOverlay

var main_scene_path = "res://scenes/main/Main_Scene.tscn"
var text1_playtime = 7.5
var text2_playtime = 2.0
var fade_out_time = 2.5
var idle_time = 1.0

@export var text1 = "In more than 60 countries, members of the LGBTQIA+ community are criminalized and punished with imprisonment or the death penalty."
@export var text2 = "This could be one of their stories..."

var current_tween: Tween
var current_step = 0 #0 = Text 1, 1 = Text 2, 2 = Fade Out
var last_visible_chars = 0
var is_typing = false

func _ready():
	fade_overlay.modulate.a = 0.0
	prompt_label.modulate.a = 0.0
	start_text(text1, text1_playtime)

func start_text(text_context: String, playtime: float):
	text_label.text = text_context
	text_label.visible_ratio = 0.0
	last_visible_chars = 0
	is_typing = true
	prompt_label.modulate.a = 0.0
	
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.tween_property(text_label, "visible_ratio", 1.0, playtime)
	current_tween.tween_callback(on_text_finished)

func on_text_finished():
	is_typing = false
	text_label.visible_ratio = 1.0
	var prompt_tween = create_tween()
	prompt_tween.tween_interval(idle_time)
	prompt_tween.tween_property(prompt_label, "modulate:a", 1.0, 0.5)

func _input(event):
	var is_skip_button = event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)
	
	if is_skip_button:
		if is_typing:
			if current_tween:
				current_tween.kill()
			on_text_finished()
		elif current_step < 2:
			current_step += 1
			if current_step == 1:
				start_text(text2, text2_playtime)
			elif current_step == 2:
				start_fade_out()

func start_fade_out():
	prompt_label.modulate.a = 0.0
	if current_tween:
		current_tween.kill()
	current_tween = create_tween()
	current_tween.tween_property(fade_overlay, "modulate:a", 1.0, fade_out_time)
	current_tween.tween_callback(start_game)

func _process(_delta):
	if is_typing and text_label.visible_characters > last_visible_chars:
		last_visible_chars = text_label.visible_characters
		var current_text = text_label.text
			
		if last_visible_chars > 0 and last_visible_chars <= current_text.length():
			if current_text[last_visible_chars - 1] != " ":
				audio_player.pitch_scale = randf_range(0.95, 1.05)
				audio_player.play()

func start_game():
	get_tree().change_scene_to_file(main_scene_path)
