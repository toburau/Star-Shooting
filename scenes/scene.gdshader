shader_type canvas_item;

void fragment() {
    // UV (0〜1) を (-1〜1) の空間に
    vec2 centered_uv = UV * 2.0 - 1.0;

    // 中心からの距離（半径1の円）
    float dist = length(centered_uv);

    // 円の外側なら透明にする
    if (dist > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0); // 完全に透明
    } else {
        // 円の内側は元のテクスチャをそのまま表示
        //COLOR = texture(TEXTURE, UV);
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	}



}


//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
