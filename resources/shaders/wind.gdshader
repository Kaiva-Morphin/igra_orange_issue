shader_type canvas_item;

varying vec2 world_pos;
void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
	vec2 px = vec2(1.0 / tex_size.x, 1.0 / tex_size.y);
	float max_offset = 1.0;
	float wave_len = 2.0;
	float speed_scale = 7.0;
	//  +
	float wpy = floor(world_pos.y * 0.25);
	float v = px.y * ((floor(sin(floor((world_pos.x + wpy) / wave_len) + TIME * speed_scale) * max_offset) / max_offset - 1.0) + 0.1);

	vec4 col = texture(TEXTURE, UV);
	vec4 shifted_color = texture(
		TEXTURE,
		UV +
		vec2(
			px.x * 0.1,
			v
		)
	);
	COLOR = shifted_color;
}
