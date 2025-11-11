extends Node3D

@export var arm_speed := 1.0
@export var arm_off_z := 0.8
@export var arm_on_z := -0.6
var arm_rate = 0
var arm_state := 0
@export var close_speed := 4.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match arm_state:
		0: #待機
			arm_rate = 0
			$arm/Area3D/CollisionShape3D.disabled = true
			$CollisionShape3D.disabled = true
		1: #伸びる
			$arm/Area3D/CollisionShape3D.disabled = false
			$CollisionShape3D.disabled = false
			arm_rate += arm_speed * delta
			if arm_rate >= 1.0:
				arm_rate = 1.0
				arm_close()
		2: #アーム閉じ待ち
			if not $arm/AnimationPlayer.is_playing():
				arm_state = 3
		3: #縮む
			arm_rate -= arm_speed * delta
			if arm_rate <= 0.0:
				arm_rate = 0.0
				arm_state = 0
				$arm/AnimationPlayer.seek(0, true)
	position.z = lerp(arm_off_z, arm_on_z, arm_rate)
	
func move() -> void:
	if arm_state != 0:
		return
	arm_state = 1

func arm_close() -> void:
	$arm/AnimationPlayer.speed_scale = close_speed
	$arm/AnimationPlayer.play("Move")
	arm_state = 2

func _on_area_3d_body_entered(body: Node3D) -> void:
	emit_signal("touched", body)
	if arm_state == 1:
		arm_close()
	
signal touched(body)
