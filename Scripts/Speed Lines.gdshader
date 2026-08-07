shader_type canvas_item;

uniform float Line_Count : hint_range(50.0, 500.0) = 220.0;
uniform float Line_Density : hint_range(0.1, 1.0) = 0.5;
uniform float Line_Sharpness : hint_range(0.01, 0.3) = 0.3;
uniform float Inner_Radius : hint_range(0.0, 1.0) = 0.4;
uniform float Line_Speed : hint_range(0.0, 30.0) = 12.0;
uniform float Rotation_Speed : hint_range(-2.0, 2.0) = 2.0;
uniform float Line_Alpha : hint_range(0.0, 1.0) = 0.7;
uniform vec4 Line_Color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

float hash(float n) {
	return fract(sin(n) * 43758.5453123);
}

void fragment() {
	vec2 st = (UV - vec2(0.5)) * vec2(SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x, 1.0);
	float Distance = length(st);
	float Angle = atan(st.y, st.x) + (TIME * Rotation_Speed);
	float Angle_ID = floor((Angle + 3.14159) / (2.0 * 3.14159) * Line_Count);
	float Time_Step = floor(TIME * Line_Speed);
	float Angle_Fraction = fract((Angle + 3.14159) / (2.0 * 3.14159) * Line_Count) - 0.5;
	float Line = smoothstep(Line_Sharpness, 0.0, abs(Angle_Fraction));
	float Line_Exists = step(1.0 - Line_Density, hash(Angle_ID * 12.34 + Time_Step));
	float Center_Mask = smoothstep(Inner_Radius, Inner_Radius + 0.2, Distance);
	float Alpha = Line * Line_Exists * Center_Mask * Line_Alpha;
	COLOR = vec4(Line_Color.rgb, Line_Color.a * Alpha);
}