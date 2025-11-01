extends CharacterBody3D

# parameters
@export var speed = 5.0
@export var updown_scale = 1.0
@export var left_sensitivity: float = 0.8
@export var right_sensitivity: float = 1.0
@export var move_acceleration := 2.0
@export var move_deceleration := 1.0
@export var rot_x_smoothness := 1.0
@export var rot_y_smoothness := 1.0
@export var arm_speed := 1.0


const deadzone = 0.13

# スティック軸の番号（DualSenseなどの標準マッピング）
const LEFT_X = JOY_AXIS_LEFT_X
const LEFT_Y = JOY_AXIS_LEFT_Y
const RIGHT_X = JOY_AXIS_RIGHT_X
const RIGHT_Y = JOY_AXIS_RIGHT_Y

@onready var camera = $Pivot/Camera3D
@onready var pivot = $Pivot

# カメラ左右回転量
var look_x_current := 0.0
# カメラ上下角度
var pitch_current := 0.0
var pitch := 0.0
# アーム座標
var arm_off_z := 0.2
var arm_on_z := -0.5
var arm_duration = 2.0
var arm_time = 0
var arm_state := 0

func _ready():
	pass

func _input(event):
	pass

func _physics_process(delta):
	
	# --- カメラ回転(右スティック) ----
	var look_x = Input.get_joy_axis(0, RIGHT_X)
	var look_y = Input.get_joy_axis(0, RIGHT_Y)
	look_x = look_x if abs(look_x) > deadzone else 0.0
	look_y = look_y if abs(look_y) > deadzone else 0.0
	look_x_current = lerp(look_x_current, -look_x * right_sensitivity, rot_x_smoothness * delta)
	rotate_y(look_x_current * delta)
	pitch_current = lerp(pitch_current, -look_y * right_sensitivity, rot_y_smoothness * delta)
	pitch += pitch_current * delta
	pivot.rotation.x = pitch

	# --- 移動（左スティック） ---
	var move_x = Input.get_joy_axis(0, LEFT_X)
	var move_y = Input.get_joy_axis(0, LEFT_Y)
	if Input.is_action_pressed("move_left"):
		move_x -= 1.0
	if Input.is_action_pressed("move_right"):
		move_x += 1.0
	if Input.is_action_pressed("move_forward"):
		move_y -= 1.0
	if Input.is_action_pressed("move_backward"):
		move_y += 1.0
	var direction = Vector3.ZERO
	var forward = -pivot.global_transform.basis.z
	var right = pivot.global_transform.basis.x
	var up = pivot.global_transform.basis.y
	if abs(move_x) > deadzone:
		direction += right * move_x     # 左右
	if abs(move_y) > deadzone:
		direction -= forward * move_y     # 前後（Y軸とは別）
	if Input.is_action_pressed("move_up"):
		direction += up * updown_scale
	if Input.is_action_pressed("move_down"):
		direction -= up * updown_scale

	var target_velocity = direction.normalized() * speed
	velocity = velocity.move_toward(target_velocity, (move_acceleration if direction.length() > 0 else move_deceleration) * delta)
		
	move_and_slide()

	if Input.is_action_just_pressed("action"):
		$Pivot/Camera3D/arm.move()

func _on_area_3d_body_entered(body) -> void:
	if body.is_in_group("meteor"):
		camera.shake()
		var dir = (global_position - body.global_position).normalized()
		var bounce_force = 3.0
		velocity += dir * bounce_force
		body.velocity -= dir * bounce_force
	elif body.is_in_group("debris"):
		camera.shake()
		# 爆発などの演出
		body.queue_free()
		
