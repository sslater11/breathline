shader_type canvas_item;

uniform vec4 glow_color; // No hint_color
uniform float glow_strength;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//vec4 glow = glow_color * glow_strength;

//	COLOR = tex_color + glow;
// Called for every pixel the material is visible on.


    vec4 tex_color = texture(TEXTURE, UV);
    vec4 glow = glow_color * glow_strength;
    COLOR = tex_color + glow;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
