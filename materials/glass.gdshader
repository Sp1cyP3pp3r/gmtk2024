shader_type spatial;

uniform sampler2D glass_texture;
uniform float alpha = 1;

void fragment() {
    vec4 glass_color = texture(glass_texture, SCREEN_UV);
    ALBEDO = glass_color.rgb;
	ALPHA = alpha;
}