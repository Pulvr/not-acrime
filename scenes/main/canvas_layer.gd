extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect

func _ready() -> void:
	fade_rect.color.a = 0.0
	fade_from_black(3)

func fade_to_black(duration: float) -> void:
	visible = true
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duration)
	await tween.finished
	
func fade_from_black(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 0.0, duration)
	await tween.finished
	visible = false
