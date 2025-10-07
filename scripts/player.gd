extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var mouse_sensitivity: float = 0.002
@onready var camera = $Camera3D
@onready var pivot = $Pivot
@export var speed = 5.0

const  deadzone = 0.07
@export var left_sensitivity: float = 0.8
@export var right_sensitivity: float = 1.0

var rotation_y = 0.0
var rotation_x = 0.0
var pitch := 0.0

# スティック軸の番号（DualSenseなどの標準マッピング）
const LEFT_X = JOY_AXIS_LEFT_X
const LEFT_Y = JOY_AXIS_LEFT_Y
const RIGHT_X = JOY_AXIS_RIGHT_X
const RIGHT_Y = JOY_AXIS_RIGHT_Y



func _ready():
	pass
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # マウスカーソルを中央に固定

func _input(event):
	pass
	#if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
	#	rotation_y -= event.relative.x * mouse_sensitivity
	#	rotation_x -= event.relative.y * mouse_sensitivity
	#	rotation_x = clamp(rotation_x, -1.5, 1.5) # 上下の角度制限
	#	rotation.y = rotation_y
	#	camera.rotation.x = rotation_x

	# ESCキーでマウスを解放
	#if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
	#	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	var look_x = Input.get_joy_axis(0, RIGHT_X)
	var look_y = Input.get_joy_axis(0, RIGHT_Y)
	if abs(look_x) > deadzone:
		rotate_y(-look_x * right_sensitivity * delta)
	if abs(look_y) > deadzone:
		pitch += -look_y * right_sensitivity * delta
		pivot.rotation.x = pitch
		pass
#		rotation_y -= look_x * right_sensitivity * delta
#		rotation_x -= look_y * right_sensitivity * delta
#		rotation_x = clamp(rotation_x, -1.5, 1.5) # 上下の角度制限
#		rotation.y = rotation_y
#		camera.rotation.x = rotation_x
#		rotate_object_local(Vector3.UP, -look_x * right_sensitivity * delta)
#		rotate_object_local(Vector3.RIGHT, -look_y * right_sensitivity * delta)
	
	
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	if direction != Vector3.ZERO:
		direction = direction.normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	move_and_slide()
