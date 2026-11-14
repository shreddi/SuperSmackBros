shader_type canvas_item;

// Procedural rising fire. Rendered on a fine pixel grid so it stays crisp and
// retro-looking but at far higher resolution than the old 220px sprite sheet.
uniform float pixel_size : hint_range(1.0, 8.0) = 3.0;
uniform float fire_height : hint_range(0.1, 1.0) = 0.55;
uniform float speed : hint_range(0.1, 3.0) = 1.0;
uniform float intensity : hint_range(0.0, 1.5) = 1.0;
uniform float opacity : hint_range(0.0, 1.0) = 0.85;

float hash(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x),
			mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 5; i++) {
		v += a * noise(p);
		p = p * 2.03 + vec2(17.3, 9.1);
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 screen = vec2(1.0) / SCREEN_PIXEL_SIZE;
	vec2 res = UV * screen;
	// Snap to a coarse grid for the pixel-art look.
	vec2 cell = floor(res / pixel_size);
	vec2 grid = vec2(screen.x, screen.y) / pixel_size;
	vec2 uv = cell / grid;
	float aspect = grid.x / grid.y;

	float t = TIME * speed;
	float h = 1.0 - uv.y; // height above the bottom edge, 0..1
	float rise = 1.0 - clamp(h / fire_height, 0.0, 1.0); // 1 at the bottom, 0 at the flame tips

	// Tall, narrow noise scrolling upward gives licking tongues of flame.
	vec2 p = vec2(uv.x * aspect * 5.0, h * 2.2 - t * 1.1);
	vec2 q = vec2(fbm(p + vec2(0.0, t * 0.3)), fbm(p + vec2(5.2, 1.3)));
	float n = fbm(p + (q - 0.5) * 1.6);

	// Flames are strongest at the base and thin out toward the tips.
	float heat = (n * 1.1 + rise * 1.15 - 0.62) * intensity;
	heat = clamp(heat, 0.0, 1.0);

	// Quantise heat into a hand-picked palette (no AI-gradient mush).
	vec3 c0 = vec3(0.10, 0.0, 0.0);
	vec3 c1 = vec3(0.55, 0.05, 0.02);
	vec3 c2 = vec3(0.92, 0.22, 0.04);
	vec3 c3 = vec3(1.0, 0.55, 0.05);
	vec3 c4 = vec3(1.0, 0.85, 0.25);
	vec3 c5 = vec3(1.0, 0.97, 0.75);
	vec3 col = c0;
	float a = 0.0;
	if (heat > 0.08) { col = c1; a = 0.55; }
	if (heat > 0.22) { col = c2; a = 0.8; }
	if (heat > 0.40) { col = c3; a = 0.9; }
	if (heat > 0.58) { col = c4; a = 0.95; }
	if (heat > 0.88) { col = c5; a = 1.0; }

	// Embers drifting up.
	vec2 ep = vec2(uv.x * aspect * 60.0, h * 40.0 - t * 6.0);
	float ember = step(0.992, hash(floor(ep))) * step(0.05, rise);
	if (ember > 0.0 && a == 0.0) { col = c4; a = 0.9; }

	COLOR = vec4(col, a * opacity);
}
