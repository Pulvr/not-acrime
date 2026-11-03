extends Node

var skip_intro: bool = false
var no_clip: bool = false

# Set Skip Intro Boolean
func _input(event):
	if GlobalSettings.last_scene == 0:
		if event.is_action_pressed("skip_intro_dialog") and skip_intro:
			skip_intro = false
			print("Intro and welcome dialogue will be played.")
		elif event.is_action_pressed("skip_intro_dialog"):
			skip_intro = true
			print("Intro and welcome dialogue will be skipped.")
	if event.is_action_pressed("activate_no_clip") and no_clip:
		no_clip = false
		print("Noclip-Mode deactivated.")
	elif event.is_action_pressed("activate_no_clip"):
		no_clip = true
		print("Noclip-Mode activated.")
