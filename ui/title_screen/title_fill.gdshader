shader_type canvas_item;

// Vertical gradient + diagonal shine sweep for the title lettering.
uniform vec4 top_color : source_color = vec4(1.0, 0.95, 0.65, 1.0);
uniform vec4 bottom_color : source_color = vec4(1.0, 0.7, 0.0, 1.0);
uniform vec4 rim_color : source_color = vec4(1.0, 1.0, 0.9, 1.0);
uniform float y_top = 0.0;
uniform float y_bottom = 100.0;
uniform float shine_pos = -1.0; // 0..1 sweeps across, outside range = off
uniform float width = 400.0;

varying vec2 local;

void vertex() {
	local = VERTEX;
}

void fragment() {
	float g = clamp((local.y - y_top) / (y_bottom - y_top), 0.0, 1.0);
	// Hard-stepped 2-tone: bright upper half, richer lower half, like a bevel.
	vec3 col = mix(top_color.rgb, bottom_color.rgb, smoothstep(0.35, 0.65, g));
	// Thin bright rim along the top of each letter.
	col = mix(col, rim_color.rgb, (1.0 - smoothstep(0.0, 0.1, g)) * 0.6);
	// Diagonal shine band.
	float d = (local.x + local.y * 0.6) / (width + (y_bottom - y_top) * 0.6);
	float band = smoothstep(0.07, 0.0, abs(d - shine_pos));
	col += band * 0.55;
	COLOR = vec4(col, COLOR.a);
}
