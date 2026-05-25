shader_type spatial;
render_mode unshaded, fog_disabled, depth_test_disabled, depth_draw_never;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_nearest;
const int pixel_size = 4; //resolution must be divisible by pixel_size

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	float x = float(int(FRAGCOORD.x) % pixel_size);
	float y = float(int(FRAGCOORD.y) % pixel_size);

	x = FRAGCOORD.x + floor(float(pixel_size) / 2.0) - x;
	y = FRAGCOORD.y + floor(float(pixel_size) / 2.0) - y;

	ALBEDO = texture(SCREEN_TEXTURE, vec2(x, y) / VIEWPORT_SIZE).xyz;
}