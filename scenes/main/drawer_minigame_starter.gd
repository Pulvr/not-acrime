class_name DrawerMinigameStarter
extends StaticBody3D

## Optional: Falls du einen festen Animationsnamen angeben möchtest.
## Wenn leer, sucht das Skript automatisch die erste gültige Animation (wie in deiner Vorlage).
@export var drawer_animation_name: String = ""

var is_open: bool = false

# Pfad ausgehend vom DrawerInteractable-Node hoch zu office_table/AnimationPlayer:
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"


func interact() -> void:
	# Verhindert, dass man während der laufenden Bewegung erneut interagiert
	if not animation_player or animation_player.is_playing():
		return

	var anim_to_play: String = _get_target_animation()
	if anim_to_play.is_empty():
		return

	if is_open:
		animation_player.play_backwards(anim_to_play)
		is_open = false
	else:
		animation_player.play(anim_to_play)
		is_open = true


func _get_target_animation() -> String:
	if (
		not drawer_animation_name.is_empty()
		and animation_player.has_animation(drawer_animation_name)
	):
		return drawer_animation_name

	for anim in animation_player.get_animation_list():
		# Die interne "RESET"-Animation von Godot überspringen, sonst bewegt sich nichts
		if anim != "RESET":
			return anim

	return ""
