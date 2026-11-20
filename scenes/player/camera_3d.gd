extends Camera3D


func _ready() -> void:
	fov = GlobalSettings.field_of_view
	GlobalSettings.global_settings_changed.connect(_on_global_settings_changed)


func _on_global_settings_changed() -> void:
	fov = GlobalSettings.field_of_view
