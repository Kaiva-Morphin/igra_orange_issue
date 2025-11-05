shader_type canvas_item;
uniform sampler2D noise_texture : source_color, filter_linear, repeat_enable;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

varying vec2 world_pos;
void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec3 ice = vec3(173, 255, 255) / 255.0;
	vec3 ice2 = vec3(143, 214, 255) / 255.0;
	vec3 water = vec3(74, 132, 138) / 255.0;

	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
	vec2 px = vec2(1.0 / tex_size.x, 1.0 / tex_size.y);

	float max_offset = 2.0;
	float wave_len = 4.0;
	float speed_scale = 7.0;
	float v = px.y * (floor(sin(floor(world_pos.x / wave_len) + TIME * speed_scale) * max_offset) / max_offset - 1.0);

	vec4 shifted_color = texture(
		TEXTURE,
		UV +
		vec2(
			0,
			v
		)
	);
	vec2 pixel_pos = UV * tex_size;

	//COLOR = shifted_color;

	if (
		length(screen_color.rgb - water) < .02
		&& shifted_color.a > 0.0
	) {
		COLOR = shifted_color * screen_color;
		//COLOR.a = 1.0;
	}
	else if (
		length(screen_color.rgb - ice) < .1
		&& COLOR.a > 0.0
	) {
		COLOR.a = 0.5;
	} else {
		COLOR.a = 0.0;
	}
}