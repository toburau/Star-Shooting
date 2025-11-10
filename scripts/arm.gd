extends Node3D

@export var arm_speed := 1.0
@export var arm_off_z := 0.8
@export var arm_on_z := -0.6
var arm_duration = 2.0
var arm_time = 0
var arm_state := 0
@export var close_speed := 3.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var arm_rate = 0
	match arm_state:
		0: #待機
			arm_time = 0
			$arm/Area3D/CollisionShape3D.disabled = true
			$CollisionShape3D.disabled = true
		1: #伸びる
			$arm/Area3D/CollisionShape3D.disabled = false
			$CollisionShape3D.disabled = false
			arm_time += arm_speed * delta
			arm_rate = arm_time / arm_duration
			if arm_rate >= 1.0:
				arm_rate = 1.0
				arm_state = 2
				$arm/AnimationPlayer.speed_scale = close_speed
				$arm/AnimationPlayer.play("Move")
		2: #アーム閉じ待ち
			arm_rate = 1.0
			if not $arm/AnimationPlayer.is_playing():
				arm_time = 0
				arm_state = 3
		3: #縮む
			arm_time += arm_speed * delta
			arm_rate = 1.0 - arm_time / arm_duration
			if arm_rate <= 0.0:
				arm_rate = 0.0
				arm_state = 0
				$arm/AnimationPlayer.seek(0, true)
			
	position.z = lerp(arm_off_z, arm_on_z, arm_rate)
	
func move() -> void:
	arm_state = 1


func _on_area_3d_body_entered(body: Node3D) -> void:
	emit_signal("touched", body)
	
signal touched(body)
