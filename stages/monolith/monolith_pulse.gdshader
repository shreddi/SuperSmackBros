shader_type canvas_item;
render_mode blend_add;

// Emissive "circuit" layer of the Monolith platform. A band of extra light
// travels outward from the central slit along the lines, then rests until the
// next pulse. Keep `period` equal to monolith_breath.gdshader so the slit
// flashes at the moment each pulse leaves it.

uniform float period = 3.5;          // seconds between pulses
uniform float travel_speed = 0.55;   // half-widths of the platform per second
uniform float band_width = 0.14;     // width of the travelling band (0..1 of half-width)
uniform float base_level = 0.65;     // resting brightness of the lines
uniform float pulse_gain = 1.1;      // extra brightness at the centre of the band
uniform float center_x = 0.5;        // UV x of the slit

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float d = abs(UV.x - center_x) * 2.0;           // 0 at the slit, 1 at the platform ends
	float front = mod(TIME, period) * travel_speed;
	float x = (d - front) / band_width;
	float band = exp(-x * x);
	COLOR = vec4(c.rgb * (base_level + pulse_gain * band), 1.0);
}
