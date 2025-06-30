shader_type canvas_item;

uniform sampler2D NOISE_TEXTURE;
uniform float noise_scale = 0.01;
uniform float fog_intensity = 0.35;
uniform vec4 fog_color : source_color = vec4(0.5, 0.3, 0.6, 1.0);
uniform float speed = 0.001;
uniform float horizon = 0.6;
uniform float fade_dist = 0.25;

void fragment() {
    vec2 uv = FRAGCOORD.xy / vec2(1080.0, 720.0);

    // Animate UVs over time
    vec2 p = uv * noise_scale + vec2(TIME * speed, 0.0);

    // Wrap UVs if needed (for seamless noise texture)
    vec2 wrapped_uv = fract(p);

    float n = texture(NOISE_TEXTURE, wrapped_uv).r;

    float fog = smoothstep(0.4, 1.0, n); // map noise to usable fog values

    // Apply horizon fade
    float edge = smoothstep(horizon + fade_dist, horizon, uv.y);
    fog *= edge;

    fog *= fog_intensity;

    COLOR = vec4(fog_color.rgb, fog * fog_color.a);
}
