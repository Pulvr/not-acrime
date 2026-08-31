extends StaticBody3D

@export var timeline: DialogicTimeline


func start_dialog():
	if timeline != null and Dialogic.current_timeline == null:
		Dialogic.start(timeline)
	elif Dialogic.current_timeline != null:
		print("Dialogue already running")
	else:
		print("No dialog attached to this NPC")
