shader_type spatial;
render_mode unshaded;

uniform sampler2D noise_tex;
uniform sampler2D displ_tex;

uniform vec4 top_light_color : source_color = vec4(0.6, 0.85, 1.0, 1.0);
uniform vec4 top_dark_color : source_color = vec4(0.1, 0.4, 0.7, 1.0);
uniform vec4 bot_light_color : source_color = vec4(0.8, 0.95, 1.0, 1.0);
uniform vec4 bot_dark_color : source_color = vec4(0.2, 0.5, 0.8, 1.0);

uniform float displ_amount : hint_range(0.0, 0.2) = 0.02;
uniform float bottom_foam_threshold : hint_range(0.0, 1.0) = 0.48;
uniform float speed : hint_range(0.0, 5.0) = 0.25;

void fragment()
{
	vec2 displ = texture(displ_tex, UV - TIME * speed / 8.0).xy;
	displ = ((displ * 2.0) - 1.0) * displ_amount;

	float noise = texture(noise_tex, vec2(UV.x, UV.y / 3.0 - TIME * speed / 4.0) + displ).x;
	noise = floor(noise * 4.0) / 4.0;

	vec4 col = mix(
		mix(top_dark_color, bot_dark_color, UV.y),
		mix(top_light_color, bot_light_color, UV.y),
		noise
	);
	col = mix(vec4(1.0, 1.0, 1.0, 1.0), col, step(UV.y + displ.y, bottom_foam_threshold));

	ALBEDO = col.rgb;
}