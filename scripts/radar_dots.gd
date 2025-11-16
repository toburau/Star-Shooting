extends Node2D

@export var player: Node3D

var targets: Array[Node]  # 表示したい敵やアイテムなど

# レーダーの半径（UIの半径）
var radar_radius := 100.0

# 実際にレーダーに表示する距離の最大値（ゲーム内距離）
@export var radar_range := 20.0

func _ready():
	pass

func add_targets():
	targets = get_tree().get_nodes_in_group("debris")
	
func _draw():
	if not player:
		return

	for target in targets:
		if not target: continue

		# --- 3D世界の座標差 ---
		var diff = target.global_transform.origin - player.global_transform.origin

		# レーダーの表示範囲外なら表示しない
		if diff.length() > radar_range:
			continue

		# --- 3D→2D に変換（Y は無視して水平面だけ）---
		var pos_2d = Vector2(diff.x, diff.z)

		# プレイヤーの向きに合わせて回転
		var angle = -player.global_rotation.y
		pos_2d = pos_2d.rotated(angle)

		# スケールをレーダーサイズに合わせる
		var scale = radar_radius / radar_range
		pos_2d *= scale

		# 中心原点を UI の中央に移動
		pos_2d += Vector2(radar_radius, radar_radius)

		# --- 点を描く ---
		draw_circle(pos_2d, 4.0, Color(1,0,0))

func _process(_delta):
	_draw()  # _draw を更新
