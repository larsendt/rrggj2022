shader_type canvas_item;
//uniform vec4 bar_color;

void fragment() {
    vec4 bar_color = vec4(1.0, 1.0, 1.0, 1.0);
    vec4 tex_color = texture(TEXTURE, UV);
    float rg = tex_color.r - tex_color.g;
    float bg = tex_color.b - tex_color.g;
    if (rg > 0.01 && bg > 0.01) {
        COLOR = vec4(bar_color.r, bar_color.g, bar_color.b, tex_color.a);
    } else {
        COLOR = tex_color;
    }
	
}
