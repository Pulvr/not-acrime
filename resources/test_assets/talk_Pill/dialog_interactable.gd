extends StaticBody3D

@export var timeline: DialogicTimeline

func startDialog():
	if timeline != null:
		Dialogic.start(timeline)
	else:
		print("No timeline assigned to this NPC!")
