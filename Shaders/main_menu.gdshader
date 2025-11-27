shader_type canvas_item;

uniform float speed = 1.0;
uniform float minStrength : hint_range(0.05, 1.0) = 0.05;
uniform float maxStrength : hint_range(0.05, 1.0) = 0.01;
uniform float strengthScale = 100.0;
uniform float interval = 3.5;
uniform float detail = 1.0;
uniform float distortion : hint_range(0.0, 1.0);
uniform float heightOffset : hint_range(0.0, 1.0);

// NEW: Control the starting direction (0.0 = Right, 3.14 = Left)
uniform float phase_offset = 0.0; 

void vertex() {
    // We add phase_offset to TIME so the wave starts at a different point
    float time = (TIME * speed) + phase_offset;
    
    float movement = cos(time) * strengthScale;
    
    VERTEX.x += movement * (1.0 - UV.y) * maxStrength; 
}