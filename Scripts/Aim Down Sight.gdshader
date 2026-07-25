shader_type canvas_item;

uniform vec4 Outer_Color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float Radius : hint_range(50.0, 1000.0) = 350.0;
uniform float Shadow_Softness : hint_range(10.0, 300.0) = 120.0;
uniform float Inner_Vignette : hint_range(0.0, 1.0) = 0.35;
uniform float Rim_Width : hint_range(0.0, 30.0) = 6.0;

void fragment() {
	vec2 Size = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 Center = Size * 0.5;
	float Distance = distance(FRAGCOORD.xy, Center);
	float Outer_Mask = smoothstep(Radius - 2.0, Radius, Distance);
	float Inner_Shadow = smoothstep(Radius - Shadow_Softness, Radius, Distance);
	float Glass_Vignette = pow(Distance / Radius, 2.0) * Inner_Vignette;
	float Rim = smoothstep(Radius - Rim_Width, Radius, Distance) * (1.0 - Outer_Mask);
	float Total_Darkness = max(Outer_Mask, max(Inner_Shadow, Glass_Vignette));
	vec3 Final_RGB = mix(Outer_Color.rgb, vec3(0.02), Rim);
	COLOR = vec4(Final_RGB, Total_Darkness * Outer_Color.a);
}
