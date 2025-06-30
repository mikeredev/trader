shader_type canvas_item;

uniform float horizon_bias : hint_range(0.0, 1.0, 0.01) = 0.8;
uniform vec4 bird_color : source_color = vec4(0.7, 0.7, 0.8, 1.0);
uniform float bird_scale : hint_range(0.0, 0.1, 0.001) = 0.001;
uniform float speed : hint_range(0.0, 0.1, 0.01) = 0.02;
uniform int bird_count : hint_range(0, 100, 1) = 4;
uniform float flock_spread : hint_range(0.0, 1.0, 0.1) = 0.1;
uniform float flap_amount : hint_range(0.0, 0.1, 0.01) = 0.01;
uniform float cluster_randomness : hint_range(0.0, 0.2, 0.01) = 0.01;


float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float block(vec2 uv, vec2 pos, vec2 size) {
    vec2 b = step(pos, uv) * step(uv, pos + size);
    return b.x * b.y;
}

void fragment() {
    vec2 uv = UV;
    vec2 grid_uv = floor(uv / bird_scale) * bird_scale;
    float mask = 0.0;

    // ----- BIRDS -----
    for (int i = 0; i < bird_count; i++) {
        float fi = float(i);
        vec2 seed = vec2(fi, fi * 1.37);

        float x = fract(hash(seed) + TIME * speed + fi * 0.17);
        float flap = sin(TIME * 2.0 + fi * 1.5) * flap_amount;
        float y = horizon_bias - 0.01 + hash(seed + 1.0) * flock_spread + flap;

        vec2 base_pos = vec2(x, y);

        vec2 p0 = vec2(0.0, 0.0);
        vec2 p1 = vec2(-bird_scale, -bird_scale * 0.5);
        vec2 p2 = vec2(bird_scale, -bird_scale * 0.5);
        vec2 p3 = vec2(0.0, -bird_scale * 1.5);

        vec2 r = vec2(
            (hash(seed + 2.0) - 0.5) * cluster_randomness,
            (hash(seed + 3.0) - 0.5) * cluster_randomness
        );

        mask += block(grid_uv, base_pos + p0 + r, vec2(bird_scale));
        mask += block(grid_uv, base_pos + p1 + r, vec2(bird_scale));
        mask += block(grid_uv, base_pos + p2 + r, vec2(bird_scale));
        mask += block(grid_uv, base_pos + p3 + r, vec2(bird_scale));
    }

    vec4 bird_result = bird_color * mask;

    COLOR = bird_result;
}
