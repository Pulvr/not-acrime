extends StaticBody3D


func interact() -> void:
	if (
		Dialogic.VAR.get("item_strings").get("item_in_hand") == "Blue Key"
		and get_parent().name == "BlueCell"
	):
		Dialogic.VAR.characters.blue.door_opened = true
		disable_lock_collider()

	if (
		Dialogic.VAR.get("item_strings").get("item_in_hand") == "Orange Key"
		and get_parent().name == "OrangeCell"
	):
		Dialogic.VAR.characters.orange.door_opened = true
		disable_lock_collider()


func disable_lock_collider() -> void:
	for child in get_children():
		if child.is_in_group("door"):
			child.set_deferred("disabled", true)
