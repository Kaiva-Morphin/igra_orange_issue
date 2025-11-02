shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float p = progress * 1.2;
	float vignette_strength = 0.9;
	vec2 centered_uv = (UV - 0.5) * 2.0;
	float vignette = 1.0 - dot(centered_uv, centered_uv) * 0.5;
	COLOR.rgb = vec3(0.0);
	if (p > 0.0) {
		if (vignette > p) {
			COLOR.a = 0.0;
		} else if (vignette > p - 0.1) {
				//vignette - progress = - 0.1 .. 0.0
				vignette = (vignette - p) * -1.0;
				COLOR.a = vignette * 10.;
		} else {
			COLOR.a = 1.0;
		}
	} else {
		COLOR.a = 0.0;
	}
}