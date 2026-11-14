shader_type canvas_item;
render_mode blend_add;

// Used by the slit layer and the underglow. Breathes gently, and flashes once
// per `period` (matching monolith_pulse.gdshader) as each pulse is emitted.

uniform float period = 3.5;
uniform float breath_speed = 1.6;
uniform float breath_amount = 0.18;
uniform float flash_amount = 0.6;
uniform float flash_width = 0.22;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float t = mod(TIME, period) / flash_width;
	float flash = exp(-t * t);
	float k = 1.0 + breath_amount * sin(TIME * breath_speed) + flash_amount * flash;
	COLOR = vec4(c.rgb * k, c.a);
}
