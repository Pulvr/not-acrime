extends StaticBody3D


func interact():
	if Dialogic.current_timeline == null:
		Dialogic.start("cell_lock_timeline")