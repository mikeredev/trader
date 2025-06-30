shader_type canvas_item;

uniform vec2 viewport_size = vec2(640.0, 360.0); // update from item_rect_changed

uniform float horizon_bias : hint_range(0.0, 1.0, 0.01) = 0.6;
uniform float horizon_fade_range : hint_range(0.0, 1.0, 0.01) = 0.25;

uniform float star_density : hint_range(300.0, 600.0, 1.0) = 500.0;

uniform float twinkle_min_freq : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float twinkle_max_freq : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float twinkle_amplitude : hint_range(0.0, 1.0, 0.1) = 0.4;
uniform float twinkle_base : hint_range(0.0, 1.0, 0.1) = 0.6;
uniform int twinkle_steps : hint_range(1, 5, 1) = 5;

uniform float circular_motion_radius : hint_range(0.0, 5.0, 0.1) = 0.5;
uniform float circular_motion_speed : hint_range(0.0, 0.01, 0.001) = 0.001;

float hash(vec2 p) {
    p = fract(p * 0.3183099 + vec2(0.71, 0.113));
    return fract(19.0 * p.x * p.y * (p.x + p.y));
}

vec3 star_color(float seed) {
    float tint = 0.95 + 0.05 * fract(seed * 17.123);
    return vec3(1.0, tint, tint); // Slight pinkish-white variation
}

void fragment() {
    vec2 uv = FRAGCOORD.xy / viewport_size;

    // Fade out near horizon
    float horizon_fade = smoothstep(horizon_bias + horizon_fade_range, horizon_bias, uv.y);
    if (horizon_fade <= 0.0) {
        discard;
    }

    // Circular drift
    vec2 motion_offset = vec2(
        cos(TIME * circular_motion_speed),
        sin(TIME * circular_motion_speed)
    ) * circular_motion_radius;
    uv += motion_offset;

    // Star field quantization
    vec2 grid_uv = uv * star_density;
    vec2 cell = floor(grid_uv);
    vec2 local = fract(grid_uv);

    float r1 = hash(cell);
    float r2 = hash(cell + 37.3);
    float r3 = hash(cell + 19.7);

	float is_star = step(0.995, r1);
	if (is_star < 0.5) discard;


    // Slight jitter to break visible grid pattern
    local += vec2(r2 - 0.5, r3 - 0.5) * 0.3;

    float dist = length(local - 0.5);
    float falloff = smoothstep(5.0, 0.0, dist);

    // Twinkle quantized to steps
    float freq = mix(twinkle_min_freq, twinkle_max_freq, fract(r1 * 3.73));
    float phase = r2 * 6.2831;
    float twinkle = twinkle_base + twinkle_amplitude * sin(TIME * freq + phase);
    twinkle = clamp(twinkle, 0.0, 1.0);
    twinkle = floor(twinkle * float(twinkle_steps)) / float(twinkle_steps);

    float brightness = falloff * twinkle * horizon_fade;

    COLOR = vec4(star_color(r1), brightness);
}
