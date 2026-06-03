extends Control

signal lock_opened
signal minigame_closed

func _on_lock_opened():
	lock_opened.emit()
	close_minigame()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		minigame_closed.emit()
		close_minigame()

func close_minigame():
	queue_free()
