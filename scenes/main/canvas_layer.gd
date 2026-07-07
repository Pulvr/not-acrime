extends CanvasLayer

@onready var fade_rect: ColorRect = $FadeRect

func _ready() -> void:
	fade_rect.color.a = 0.0
	visible = false

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

func snap_to_black() -> void:
	visible = true
	fade_rect.color.a = 1.0
	
func snap_from_black() -> void:
	visible = false
	fade_rect.color.a = 0.0

func change_scene(path: String, fade_time := 0.5, auto_fade_in := true) -> void:
	await fade_to_black(fade_time)
	get_tree().change_scene_to_file(path)
	await get_tree().process_frame
	await get_tree().process_frame
	if auto_fade_in:
		await fade_from_black(fade_time)
		
func change_scene_after_intro(path: String, fade_time := 1.0) -> void:
	snap_to_black()
	get_tree().change_scene_to_file(path)
	await wait_frames(2)
	await fade_from_black(fade_time)
		
func wait_frames(count: int) -> void:
	for i in count:
		await get_tree().process_frame
