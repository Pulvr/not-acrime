extends Control

@export var text_1 = "There are still countries imposing the death penalty for homosexuality."
@export var text_2 = "Did you read the newspaper headlines on the wall?"
@export var text_3 = "Those were all real."
@export var text_4 = "Criminalization of LGBTIQ* people is still on the rise."
@export var text_5 = "Stand together."
@export var text_6 = "LGBTIQ* Rights are Human Rights."
@export var text_7 = "..."
@export var text_8 = "Thank you for playing!"
@export var text_9 = "This is the end of our playtest demo..."
@export var text_10 = "...made by Florian Wendel, Sebastian Grewe and Oskar Kotte."
@export var text_11 = "Proudly developed using Godot 4 and Dialogic 2."
@export var text_12 = "Newspaper Sources (all last visited on 02-07-2026, 14:00 (UTC+02:00)): \n
	Sekulich, H. (2026, May 30). Ghana parliament passes bill criminalising gay acts. https://www.bbc.com/news/articles/c5yedendprko \n
	Dallara, A., Dallara, A., & Dallara, A. (2025, July 22). Trump administration hits shameful milestone of 300 Anti-LGBTQ actions, statements, and policies against the community. GLAAD | GLAAD Rewrites the Script for LGBTQ Acceptance. https://glaad.org/trump-administration-hits-shameful-milestone-of-300-anti-lgbtq-actions-statements-and-policies-against-the-community/ \n
	Atuhaire, B. P. (2023, March 22). Uganda Anti-Homosexuality bill: Life in prison for saying you're gay. https://www.bbc.com/news/world-africa-65034343"

const MAIN_MENU_PATH = "res://scenes/ui_scenes/main_menu.tscn"

var fade_out_time = 2.5
var idle_time = 1.0

var texts: Array = []
var playtimes: Array = []

var current_tween: Tween
var current_step = 0        
var last_visible_chars = 0
var is_typing = false

@onready var text_label = $RichTextLabel
@onready var prompt_label = $PromptLabel
@onready var audio_player = $AudioStreamPlayer2D
@onready var fade_overlay = $FadeOverlay

func _ready():
	texts = [text_1, text_2, text_3, text_4, text_5, text_6, text_7, text_8, text_9, text_10, text_11, text_12]
	playtimes = [3, 3, 1, 3, 2, 2, 1, 1, 2, 2, 2, 3]

	fade_overlay.modulate.a = 0.0
	prompt_label.modulate.a = 0.0
	start_text(texts[0], playtimes[0])

func _process(_delta):
	if is_typing and text_label.visible_characters > last_visible_chars:
		last_visible_chars = text_label.visible_characters
		var aktueller_text = text_label.text

		if last_visible_chars > 0 and last_visible_chars <= aktueller_text.length():
			if aktueller_text[last_visible_chars - 1] != " ":
				audio_player.pitch_scale = randf_range(0.95, 1.05)
				audio_player.play()

func _input(event):
	var is_skip_button = event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)

	if is_skip_button:
		if is_typing:
			if current_tween:
				current_tween.kill()
			_on_text_finished()
		elif current_step < texts.size():
			current_step += 1
			if current_step < texts.size():
				start_text(texts[current_step], playtimes[current_step])
			else:
				start_fade_out()

func start_text(text_context: String, playtime: float):
	text_label.text = text_context
	text_label.visible_ratio = 0.0
	last_visible_chars = 0
	is_typing = true
	prompt_label.modulate.a = 0.0

	if current_tween:
		current_tween.kill()

	current_tween = create_tween()
	current_tween.tween_interval(idle_time)
	current_tween.tween_property(text_label, "visible_ratio", 1.0, playtime)
	current_tween.tween_callback(_on_text_finished)

func start_fade_out():
	prompt_label.modulate.a = 0.0
	if current_tween:
		current_tween.kill()
	current_tween = create_tween()
	current_tween.tween_interval(idle_time)
	current_tween.tween_property(fade_overlay, "modulate:a", 1.0, fade_out_time)
	current_tween.tween_callback(switch_to_main_menu)

func _on_text_finished():
	is_typing = false
	text_label.visible_ratio = 1.0
	var prompt_tween = create_tween()
	prompt_tween.tween_interval(idle_time)
	prompt_tween.tween_property(prompt_label, "modulate:a", 1.0, 0.5)


func switch_to_main_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	FadeLayer.change_scene(MAIN_MENU_PATH)
