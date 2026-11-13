extends StaticBody3D


func interact() -> void:
	if (
		Dialogic.VAR.get("item_strings").get("item_in_hand") == "Blue Key"
		and get_parent().name == "BlueCell"
	):
		print("open blue cell")
	if (
		Dialogic.VAR.get("item_strings").get("item_in_hand") == "Orange Key"
		and get_parent().name == "OrangeCell"
	):
		print("open orange cell")
