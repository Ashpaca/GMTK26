shader_type canvas_item;
render_mode blend_mix;
uniform sampler2D gradient;
uniform float line_height;

varying float world_y;

void vertex() {
    world_y = VERTEX.y;
}

void fragment() {
    COLOR.a = texture(TEXTURE, UV).a;
    float t = clamp(mod(world_y, line_height) / line_height, 0.0, 1.0);
    COLOR.rgb = COLOR.rgb * texture(gradient, vec2(t, 0.0)).rgb;
}
