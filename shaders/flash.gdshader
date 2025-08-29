shader_type canvas_item;

uniform vec4 flash_light = vec4(1);
uniform float flash_amount = 0.0;

uniform float seed = 0;
uniform float chocolate_amount : hint_range(0.0, 1.0) = 0.1;
uniform vec4 chocolate_color : source_color = vec4(0.36, 0.20, 0.09, 1.0);


uniform vec4 line_color = vec4(1.0, 1.0, 1.0, 1.0);//color line
uniform float line_scale : hint_range(0, 20) = 0;    // thickness of the line

float rand(vec2 co) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
	vec2 size = TEXTURE_PIXEL_SIZE * line_scale;
	
	float outline = texture(TEXTURE, UV + vec2(-size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, 0)).a;
	outline += texture(TEXTURE, UV + vec2(0, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, size.y)).a;
	outline += texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
	outline += texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
	outline = min(outline, 1.0);


	vec4 color = texture(TEXTURE, UV);

    vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    vec2 pixel_coord = floor(UV * tex_size);

    // random per pixel (not subpixel)
    float r = rand(pixel_coord + seed);

    if (r < chocolate_amount) {
        color.rgb = chocolate_color.rgb;
	}

	color.rgb = mix(color.rgb, flash_light.rgb, flash_amount);
	COLOR = mix(color, line_color , outline - color.a);
}
