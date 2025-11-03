shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec4 col : source_color;

uniform float width: hint_range(0.0, 0.1, 0.0001) = 0.04;
uniform float feather: hint_range(0.0, 1.0, 0.001) = 0.135;

void fragment() {
	float p = 1.5;
	float r = 1.0 - (pow(progress, p) * 1.7 - feather * 0.5);
    vec2 st = UV;
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    float aspect_ratio = tex_size.x / tex_size.y;
    vec2 scaled_st = (st - vec2(0.0, 0.5)) / vec2(1.0, aspect_ratio) + vec2(0.0, 0.5);
    vec2 dist_center = scaled_st - vec2(0.5, 0.5);
    float mask = smoothstep(r - width - feather, r - width, length(dist_center));
	COLOR.rgb = col.rgb;
	COLOR.a = mask;
}