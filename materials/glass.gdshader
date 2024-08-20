shader_type spatial;

uniform sampler2D glass_texture;

void fragment() {
    vec4 glass_color = texture(glass_texture, SCREEN_UV);
    ALBEDO = glass_color.rgb;
}