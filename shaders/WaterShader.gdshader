shader_type spatial;


uniform float speed;
uniform sampler2D text : filter_nearest;
uniform vec2 scale = vec2(2.0, 2.0);


void fragment () {
	vec2 uv = UV * scale;
	uv += vec2(TIME * speed, -TIME * (speed/2.0));
	vec4 color = texture(text, uv);
	ALBEDO.r = color.r/5.0;
	ALBEDO.g = color.g/3.5;
	ALBEDO.b = color.b/1.0;
	ALPHA = 0.5;
}