shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE: repeat_disable, hint_screen_texture;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap;

uniform float StrokeSize: hint_range(0.0, 32.0, 0.001) = 3.5;
uniform float DepthMaskBase: hint_range(0.0, 2.0, 0.001) = 0.05;
uniform float DepthMaskIntensity: hint_range(-128.0, 128.0, 0.001) = 0.3;

const float _offsetA = 0.0002;
const float _offsetB = 0.0003;
const float _offsetC = 0.0004;


void vertex() {
  POSITION = vec4(VERTEX, 1.0);
}

vec3 find_brightest(vec2 _uv) {
	float brightest_value = 0.0;
	vec3 brightest_color = vec3(0.0);

    vec3 sample_colors[7] = vec3[](
    	texture(SCREEN_TEXTURE, _uv).rgb,
    	texture(SCREEN_TEXTURE, vec2(_uv.x, _uv.y + _offsetC * StrokeSize)).rgb,
    	texture(SCREEN_TEXTURE, vec2(_uv.x - _offsetB * StrokeSize, _uv.y + _offsetA * StrokeSize)).rgb,
    	texture(SCREEN_TEXTURE, vec2(_uv.x - _offsetB * StrokeSize, _uv.y - _offsetA * StrokeSize)).rgb,
    	texture(SCREEN_TEXTURE, vec2(_uv.x, _uv.y - _offsetC * StrokeSize)).rgb,
    	texture(SCREEN_TEXTURE, vec2(_uv.x + _offsetB * StrokeSize, _uv.y - _offsetA * StrokeSize)).rgb,
    	texture(SCREEN_TEXTURE, vec2(_uv.x + _offsetB * StrokeSize, _uv.y + _offsetA * StrokeSize)).rgb
    );

    for (int i = 0; i < 7; i++) {
        float brightness = max(max(sample_colors[i].r, sample_colors[i].g), sample_colors[i].b);
        if (brightness > brightest_value) {
            brightest_value = brightness;
            brightest_color = sample_colors[i];
        }
    }
    return brightest_color;
}

void fragment() {
	float depth        = texture(DEPTH_TEXTURE, SCREEN_UV).r;
	depth              = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]);
	float mask         = (depth*DepthMaskBase);
	vec4 modified_mask = vec4(pow(mask, DepthMaskIntensity));
	modified_mask      = clamp(modified_mask, 0.0, 1.0);
	vec3 base_color    = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
    ALBEDO = mix(base_color, find_brightest(SCREEN_UV), modified_mask.rgb).rgb;
	// uncomment to see depth mask
	//ALBEDO = modified_mask.rgb;
}
