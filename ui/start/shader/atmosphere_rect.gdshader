shader_type canvas_item;

uniform sampler2D noise_tex;
uniform float noise_scale = 2.0;
uniform float fog_intensity = 0.35;
uniform vec4 fog_color : source_color = vec4(0.5, 0.6, 0.7, 1.0);
uniform float speed = 0.01;
uniform float shimmer_amount = 0.005;

uniform float horizon = 1.0;
uniform float fade_dist = -1.0;

// Optional: vertical warping to simulate heat shimmer or rippling fog
float vertical_shimmer(vec2 uv) {
    float offset = texture(noise_tex, uv * 4.0 + vec2(TIME * 0.5, 0.0)).r;
    return shimmer_amount * (offset - 0.5);
}

void fragment() {
    vec2 uv = FRAGCOORD.xy / vec2(1080.0, 720.0);

    // Animate fog UVs with horizontal drift
    vec2 p = uv * noise_scale + vec2(TIME * speed, 0.0);
    vec2 wrapped_uv = fract(p);

    float n = texture(noise_tex, wrapped_uv).r;

    // Mist strength
    float mist = smoothstep(0.3, 1.0, n);

    // Fade in from top of fog region (below horizon)
    float edge = smoothstep(horizon, horizon + fade_dist, uv.y);

    // Optional shimmer (subtle vertical displacement)
    uv.y += vertical_shimmer(uv);

    mist *= edge;
    mist *= fog_intensity;

    COLOR = vec4(fog_color.rgb, mist * fog_color.a);
}
