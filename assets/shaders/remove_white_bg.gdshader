shader_type canvas_item;

// 흰색 배경 제거 셰이더
// 밝기가 threshold 이상인 픽셀을 투명 처리
uniform float threshold : hint_range(0.0, 1.0) = 0.85;
uniform float softness : hint_range(0.0, 0.5) = 0.1;

void fragment() {
	vec4 col = texture(TEXTURE, UV);
	float brightness = (col.r + col.g + col.b) / 3.0;
	float alpha_mask = 1.0 - smoothstep(threshold - softness, threshold + softness, brightness);
	col.a *= alpha_mask;
	COLOR = col;
}
