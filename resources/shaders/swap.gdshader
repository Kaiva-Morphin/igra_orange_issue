shader_type canvas_item;

uniform float strength: hint_range(0.0, 0.1, 0.001) = 0.08;
uniform vec2 center = vec2(0.5, 0.5);
uniform float radius: hint_range(0.0, 1.0, 0.001) = 1.0;

uniform float aberration: hint_range(0.0, 1.0, 0.001) = 0.425;
uniform float width: hint_range(0.0, 0.1, 0.0001) = 0.04;
uniform float width2: hint_range(0.0, 0.5, 0.0001) = 0.04;
uniform float feather: hint_range(0.0, 1.0, 0.001) = 0.135;
uniform float feather2: hint_range(0.0, 1.0, 0.001) = 0.135;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	float p = 1.5;
	float r = pow(radius, p);
	float r2 = pow(radius, p) - 0.02;
    vec2 st = UV;
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    float aspect_ratio = tex_size.x / tex_size.y;
    vec2 scaled_st = (st - vec2(0.0, 0.5)) / vec2(1.0, aspect_ratio) + vec2(0.0, 0.5);
    vec2 dist_center = scaled_st - center;
    float mask = (1.0 - smoothstep(r - feather, r, length(dist_center))) *
                 smoothstep(r - width - feather, r - width, length(dist_center));
	float mask2 = smoothstep(r2 - width2 - feather2, r2 - width2, length(dist_center));



    vec2 offset = normalize(dist_center) * strength * mask;
    vec2 biased_st = scaled_st - offset;
    vec2 abber_vec = offset * aberration * mask;

    vec2 final_st = st * (1.0 - mask) + biased_st * mask;

    vec4 red  = texture(TEXTURE, final_st + abber_vec);
    vec4 blue = texture(TEXTURE, final_st - abber_vec);
    vec4 ori  = texture(TEXTURE, final_st);

    vec3 rgb = vec3(red.r, ori.g, blue.b);
	rgb = rgb + rgb * mask * 0.4;

	//COLOR = vec4(vec3(mask, mask2, 0), 1.0);
	COLOR = vec4(rgb, mask2);
}
