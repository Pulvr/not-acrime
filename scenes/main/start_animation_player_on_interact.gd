extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func interact():
	for child in get_children():
		if child.is_in_group("door"):
			child.set_deferred("disabled", true)

	for animation in animation_player.get_animation_list():
		animation_player.play(animation)
		await animation_player.animation_finished
