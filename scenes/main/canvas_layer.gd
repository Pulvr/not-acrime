extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect

func _ready() -> void:
	fade_rect.color.a = 0.0

func fade_to_black(duration: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade_rect, "color:a", 1.0, duration)
	await tween.finished
