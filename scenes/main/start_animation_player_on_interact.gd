extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func interact():
	for child in get_children():
		print(child.get_groups())
		if child.is_in_group("door"):
			child.queue_free()

	for animation in animation_player.get_animation_list():
		animation_player.play(animation)
		await animation_player.animation_finished
	
