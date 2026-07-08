shader_type canvas_item;

uniform sampler2D refraction_map;
uniform sampler2D water_mask;
uniform vec2 gap_stretch = vec2(1.0, 1.0);
uniform vec2 refraction_stretch = vec2(1.0, 1.0);
uniform float refraction_strength : hint_range(0.0, 1.0) = 0.05;
uniform vec4 water_tint : source_color = vec4(0.2, 0.4, 0.8, 0.6);
uniform vec4 water_highlight : source_color = vec4(1.0, 1.0, 1.0, 0.8);
uniform float speed : hint_range(0.0, 10.0) = 2.0;
uniform float flow_gaps : hint_range(0.0, 1.0) = 0.4;
uniform float highlight_width : hint_range(0.0, 0.2) = 0.03;

uniform vec2 scale = vec2(1.0, 1.0);
uniform float zoom = 1.0;

void fragment() {
	vec2 uv = UV;

	// Refraction: sample noise, offset UV slightly
	vec2 refr_uv = uv * refraction_stretch * scale * zoom + vec2(0.0, -TIME * speed * 0.1);
	vec2 refr = texture(refraction_map, refr_uv).rg - 0.5;
	vec2 distorted_uv = uv + refr * refraction_strength;

	// Water mask: creates the flowing "gap" streaks
	vec2 mask_uv = distorted_uv * gap_stretch * scale * zoom + vec2(0.0, -TIME * speed * 0.15);
	float mask = texture(water_mask, mask_uv).r;

	float gap = smoothstep(flow_gaps, flow_gaps + highlight_width, mask);
	float highlight = smoothstep(flow_gaps - highlight_width, flow_gaps, mask) - gap;

	vec4 col = water_tint * gap;
	col += water_highlight * highlight;

	COLOR = col;
}