extends CharacterBody3D

# parameters
@export var speed = 5.0
@export var updown_scale = 2.0
@export var left_sensitivity: float = 0.8
@export var right_sensitivity: float = 1.0
@export var move_acceleration := 2.0
@export var move_deceleration := 1.0
@export var rot_x_smoothness := 1.0
@export var rot_y_smoothness := 1.0
@export var arm_speed := 1.0
@export var life = 3

const deadzone = 0.13

# スティック軸の番号（DualSenseなどの標準マッピング）
const LEFT_X = JOY_AXIS_LEFT_X
const LEFT_Y = JOY_AXIS_LEFT_Y
const RIGHT_X = JOY_AXIS_RIGHT_X
const RIGHT_Y = JOY_AXIS_RIGHT_Y

@onready var camera = $Pivot/Camera3D
@onready var pivot = $Pivot
@onready var arm = $Pivot/Camera3D/arm

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

var move_input_flag = false
var rotate_input_flag = false



func _ready():
	arm.touched.connect(_on_arm_touched)

func _input(_event):
	pass

func rotate_camera(delta):
	# --- カメラ回転(右スティック) ----
	var input_look = false
	var look_x = Input.get_joy_axis(0, RIGHT_X)
	var look_y = Input.get_joy_axis(0, RIGHT_Y)
	look_x = look_x if abs(look_x) > deadzone else 0.0
	look_y = look_y if abs(look_y) > deadzone else 0.0
	look_x_current = lerp(look_x_current, -look_x * right_sensitivity, rot_x_smoothness * delta)
	rotate_y(look_x_current * delta)
	pitch_current = lerp(pitch_current, -look_y * right_sensitivity, rot_y_smoothness * delta)
	pitch += pitch_current * delta
	pivot.rotation.x = pitch
	if look_x != 0:
		input_look = true
	if look_y != 0:
		input_look = true
	if input_look == true:
		if rotate_input_flag == false:
			rotate_input_flag = true
			#$MoveShipSound.play()
	else:
		rotate_input_flag = false

func rotate_camera2(delta):
	var look_x = Input.get_joy_axis(0, RIGHT_X)
	var look_y = Input.get_joy_axis(0, RIGHT_Y)
	look_x = look_x if abs(look_x) > deadzone else 0.0
	look_y = look_y if abs(look_y) > deadzone else 0.0
	var look_dir = Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if look_dir.length() > 0:
		# 1. 縦の回転 (ピッチ: 自分のローカルX軸で回る)
		$Pivot.rotate_object_local(Vector3.RIGHT, -look_dir.y * right_sensitivity * delta)
		# 2. 横の回転 (ヨー: 自分のローカルY軸で回る)
		$Pivot.rotate_object_local(Vector3.UP, -look_dir.x * right_sensitivity * delta)
		# 【重要】回転行列の補正
		# 計算を繰り返すと数値誤差でスケールが歪むことがあるため、正規化します
		$Pivot.transform = $Pivot.transform.orthonormalized()
		
		$Pivot.rotation.z = 0

func _physics_process(delta):
	
	rotate_camera(delta)	
	#rotate_camera2(delta)
	
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
	var is_input = false
	if abs(move_x) > deadzone:
		direction += right * move_x     # 左右
		is_input = true
	if abs(move_y) > deadzone:
		direction -= forward * move_y     # 前後（Y軸とは別）
		is_input = true
	if Input.is_action_pressed("move_up"):
		direction += up * updown_scale
		is_input = true
	if Input.is_action_pressed("move_down"):
		is_input = true
		direction -= up * updown_scale

	if is_input == true and life > 0:
		if move_input_flag == false:
			move_input_flag = true
			$MoveShipLowSound.play()
	else:
		move_input_flag = false

	var target_velocity = direction.normalized() * speed
	velocity = velocity.move_toward(target_velocity, (move_acceleration if direction.length() > 0 else move_deceleration) * delta)
	if life == 0:
		velocity = Vector3.ZERO

	move_and_slide()

	if Input.is_action_just_pressed("action") and life > 0:
		$Pivot/Camera3D/arm.move()

func _on_area_3d_body_entered(body) -> void:
	if body.is_in_group("meteor"):
		life = life - 1
		camera.shake()
		$CrushSound.play()
		var dir = (global_position - body.global_position).normalized()
		var bounce_force = 3.0
		velocity += dir * bounce_force
		body.velocity -= dir * bounce_force
	elif body.is_in_group("debris"):
		if not arm.catch_object:
			life = life - 1	 
			camera.shake()
			# 爆発などの演出
			$CrushSound.play()
			body.queue_free()
		
func _on_arm_touched(body) -> void:
	if body.is_in_group("meteor"):
		var dir = (global_position - body.global_position).normalized()
		var bounce_force = 3.0
		body.velocity -= dir * bounce_force
		$ArmHitMeteorSound.play()
	elif body.is_in_group("debris"):
		pass
