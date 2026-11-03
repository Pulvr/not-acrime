extends MeshInstance3D

@export var viewport_name: StringName = &"TopLeftCam"

func _ready():
	await get_tree().process_frame

	for viewport in get_tree().get_nodes_in_group("security_cams"):
		if viewport.name == viewport_name:
			var material := StandardMaterial3D.new()
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			material.albedo_texture = viewport.get_texture()
			set_surface_override_material(0, material)
			return
