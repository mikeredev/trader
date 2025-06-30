shader_type canvas_item;

const float screen_height = 360.0; // base scene size.x

uniform float horizon : hint_range(0.0, 1.0) = 0.85;
uniform vec4 sky_color : source_color = vec4(0.1, 0.15, 0.4, 1.0);
uniform vec4 sea_color : source_color = vec4(0.1, 0.2, 0.3, 1.0);

// wave
uniform vec4 crest_color : source_color = vec4(0.15, 0.2, 0.3, 1.0);
uniform float wave_amplitude : hint_range(0.0, 0.05) = 0.005;
uniform float wave_frequency : hint_range(0.1, 10.0) = 10.0;
uniform float wave_speed : hint_range(0.01, 0.1) = 0.01;

// band
uniform float band_height : hint_range(0.0, 0.3) = 0.00;
uniform float band_fade_range : hint_range(0.0, 1.0) = 0.75;
uniform vec4 band_color : source_color = vec4(0.35, 0.55, 0.9, 0.3);
uniform int band_steps : hint_range(0, 32, 1) = 24;

void fragment() {
    vec2 uv = UV;
    float pixel_height = 1.0 / screen_height;

    // --- Pixel quantization of y-coordinate
    float quantized_y = floor(uv.y / pixel_height) * pixel_height;

    // --- Wave computation
    float wave_phase = uv.x * wave_frequency + TIME * wave_speed * wave_frequency;
    float wave = sin(wave_phase) * wave_amplitude;
    float displaced_y = floor((horizon + wave) / pixel_height) * pixel_height;

    // --- Sea region detection
    bool is_sea = quantized_y > (horizon - 0.01);

    // --- Crest detection
    const float EPSILON = 0.001;
    bool is_crest = is_sea && (abs(quantized_y - displaced_y) < EPSILON);

    // --- Base color blending (sky vs sea)
    float t = step(quantized_y, displaced_y);
    vec4 base_color = mix(sea_color, sky_color, t);

    // --- Band bounds (starting from horizon)
    float band_top = floor(horizon / pixel_height) * pixel_height;
    float band_bottom = floor((horizon + band_height) / pixel_height) * pixel_height;

    // --- Quantized stepped alpha fade
    float alpha = 0.0;

    if (quantized_y >= band_top && quantized_y <= band_bottom) {
        alpha = 1.0;
    } else if (quantized_y > band_bottom && quantized_y < band_bottom + band_fade_range) {
        float raw_alpha = 1.0 - (quantized_y - band_bottom) / band_fade_range;
        alpha = floor(raw_alpha * float(band_steps)) / float(band_steps);
    } else if (quantized_y < band_top && quantized_y > band_top - band_fade_range) {
        float raw_alpha = 1.0 - (band_top - quantized_y) / band_fade_range;
        alpha = floor(raw_alpha * float(band_steps)) / float(band_steps);
    }

    vec4 overlay_color = vec4(band_color.rgb, band_color.a * alpha);

    // --- Final composition
    vec4 final_color = is_crest
        ? crest_color
        : mix(base_color, overlay_color, overlay_color.a);

    COLOR = final_color;
}
