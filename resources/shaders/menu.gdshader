shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float progress : hint_range(0.0, 1.0) = 0.0;

uniform float width: hint_range(0.0, 0.1, 0.0001) = 0.04;
uniform float feather: hint_range(0.0, 1.0, 0.001) = 0.135;

uniform vec4 up : source_color;
uniform vec4 bottom : source_color;

void fragment() {
	float p = 1.5;
	float r = 1.0 - (pow(progress, p) * 1.7 - feather * 0.5);
    vec2 st = UV;
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    float aspect_ratio = tex_size.x / tex_size.y;
    vec2 scaled_st = (st - vec2(0.0, 0.5)) / vec2(1.0, aspect_ratio) + vec2(0.0, 0.5);
    vec2 dist_center = scaled_st - vec2(0.5, 0.5);
    float mask = 1.0 - smoothstep(r - width - feather, r - width, length(dist_center));
	float v = progress;
	
	
	COLOR.rgb = COLOR.rgb * ((1.0 - v) + mask * v);
	
	float u = 1.0 - UV.y;
	float b = UV.y;
	vec4 mixed = bottom * b + up * u;
	COLOR.rgb = COLOR.rgb * (1.0 - mixed.a) + mixed.a * mixed.rgb;
}