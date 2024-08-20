shader_type spatial;
render_mode unshaded;



varying vec3 worldPos;
varying vec3 worldNormal;
varying vec3 worldEye;


group_uniforms color;
	uniform vec3 baseColor: source_color = vec3(1.0, 1.0, 1.0);
group_uniforms;

group_uniforms gradientBasis;
	uniform vec3 gradientBasis = vec3(3.0, 3.0, 3.0);
	uniform vec3 gradientBasisDistort = vec3(0.0, .0, 0.0);
	uniform float gradientBasisSpeed = 0.0;
group_uniforms;

group_uniforms refraction;
	uniform float refractionSplit = 2.0;
	uniform float refractionSplitPower: hint_range(0.01, 10.0) = 1.0;
	uniform float refractionAffect = 0.8;
group_uniforms;




void vertex() {

	worldNormal = (MODEL_NORMAL_MATRIX * NORMAL);
	worldPos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	worldEye = (INV_VIEW_MATRIX * vec4(EYE_OFFSET, 1.0)).xyz;

}

void fragment() {

	// Ensure the normal has a length of 1.
	vec3 fixedWorldNormal = normalize(worldNormal);

	// Get the direction we are looking towards.
	vec3 lookDir = normalize(worldPos - worldEye);

	// Get the dot product between the look direction and the normal.
	// This returns essentially how 'straight on' we are looking.
	float lookDot = pow(
		abs(dot(lookDir, fixedWorldNormal)),
		refractionSplitPower
	);

	// Get the reflection direction.
	vec3 reflectionDir = reflect(lookDir, fixedWorldNormal);

	// Assemble the gradient.
	vec3 gradientDirection = gradientBasis * reflectionDir;

	if (gradientBasisDistort != vec3(0.0)) {
		gradientDirection += sin(gradientBasisDistort * PI * reflectionDir);
	}

	float gradient = (
		  gradientDirection.x
		+ gradientDirection.y
		+ gradientDirection.z
		+ gradientBasisSpeed * TIME
	);

	// The final sine wave.
	vec3 refraction = 0.5 + 0.5 * sin(
		  vec3(-1.0, 0.0, 1.0)
		* (1.0 - lookDot)
		* refractionSplit
		+ gradient
	);

	// Construct the final color.
	vec3 color = baseColor * (1.0 - refraction * refractionAffect);

	ALBEDO = color;

}

