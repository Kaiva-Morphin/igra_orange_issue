shader_type canvas_item;
uniform sampler2D noise_texture : source_color, filter_linear, repeat_enable;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

varying vec2 world_pos;
void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

uniform vec2 frame_size;

void fragment() {
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec3 ice = vec3(173, 255, 255) / 255.0;
	vec3 ice2 = vec3(143, 214, 255) / 255.0;
	
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
	vec2 px = vec2(1.0 / tex_size.x, 1.0 / tex_size.y);
	vec4 shifted_color = texture(TEXTURE, UV + vec2(px.x, 0));
	vec2 pixel_pos = UV * tex_size;
	
	
	if (
		length(screen_color.rgb - ice) > .1
		// && length(screen_color.rgb - ice2) > .1
	) {
		COLOR.a = 0.0;
		//if (COLOR.a > 0.0) {
			//COLOR.rgba = vec4(0.0, 0.0, 0.0, 0.1);
		//}
	} else {
		//if (int(pixel_pos.y) % 3 == 0) {
			//COLOR.rgba = shifted_color;
		//}
		if (COLOR.a > 0.0) {
			COLOR.a = 0.5;
		}
		
		//if (COLOR.a > 0.0) {
			//COLOR.a = max(0.0, 1.0 - floor((frame_size.y - pixel_pos.y)) / 10.0);
		//}
	}
	
	//if (screen_color.r > 0.8) {
	//vec2 w = floor(world_pos) * 0.02; // * 0.01
	//
		//COLOR.a = 0.5;
	//}
	
	//vec4 c = COLOR;
	//vec3 ice = vec3(120, 242, 236) / 255.0;
	////float t = floor(TIME * 3.0);
	////float t = TIME * 3.0;
	//float wave = sin((w.x + w.y * 2.0) * 0.2 + TIME * 2.0) * 0.5 + 0.5;
	//vec2 px = 1.0 / vec2(128.0);
	//if (c.rgb == ice && c.a > 0.0) {
		//float v = floor(sample(
			//vec2(1.0, 3.0) * (w)
		//).r * 5.0) / 6.0;
		//float v2 = floor(sample(
			//vec2(1.0, 3.0) * (w + vec2(px.x * 5.0, px.y * 2.0))
		//).r * 5.0) / 6.0;
		//float e = 0.0;
		////COLOR.r = v;
		////COLOR.g = v2;
		//COLOR.rgb = vec3(0.5, 0.75, 0.9) * ((1.0 - v2) * 0.9 + v * 0.3) * 1.6;
		//float v_i = texture(noise_texture, w).r;
		//float v2 = texture(noise_texture, w - 0.02).r;
		
		//COLOR.rgb = vec3(v) * 0.5;
		//if (v2 < 0.5) {
			//COLOR.r = 0.0;
		//}
		//if (v < 0.5) {
			//COLOR.r = 0.7;
		//}
		
		
		//if (v > e && v < e + 0.1) {
			//COLOR.r = 1.0;
		//}
	//}
}