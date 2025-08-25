shader_type canvas_item;

uniform vec4 flash_light = vec4(1);
uniform float flash_amount = 0.0;

void fragment() {
	vec4 color = texture(TEXTURE, UV);
	color.rgb = mix(color.rgb, flash_light.rgb, flash_amount);
	COLOR = color;
}