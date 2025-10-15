extends Camera3D

var shake_strength := 0.0
var shake_decay := 0.8      # 揺れが収まる速さ
var shake_amount := 0.6     # 揺れの強さ（3Dでは小さめ）
var shake_offset := Vector3.ZERO

func _ready():
	pass

func _process(delta):
	var base = get_parent().transform
	if shake_strength > 0:
		shake_strength = max(shake_strength - shake_decay * delta, 0)
		# ランダムな揺れベクトルを生成
		shake_offset = Vector3(
			randf_range(-1, 1),
			randf_range(-1, 1),
			randf_range(-1, 1)
		) * shake_strength * shake_amount
	else:
		shake_offset = Vector3.ZERO
	
	#global_position += shake_offset
	transform = base.translated(shake_offset)

func shake(intensity := 1.0):
	shake_strength = shake_amount * intensity
