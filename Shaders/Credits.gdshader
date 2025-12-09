shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float blur_amount : hint_range(0.0, 5.0) = 1.0;

void fragment() {
    // This samples the screen *behind* this object and blurs it
    COLOR = textureLod(screen_texture, SCREEN_UV, blur_amount);
}