extends CharacterBody3D

@export var rotation_speed := Vector3.ZERO
@export var rotation_range := 30.0
@export var move_speed := Vector3.ZERO
@export var move_range := 0.1

func _ready() -> void:
	rotation_speed = Vector3(
		randf_range(-rotation_range, rotation_range),
		randf_range(-rotation_range, rotation_range),
		randf_range(-rotation_range, rotation_range),
	)
	move_speed = Vector3(
		randf_range(-move_range, move_range),
		randf_range(-move_range, move_range),
		randf_range(-move_range, move_range),
	)

func _physics_process(delta: float) -> void:
	rotation_degrees += rotation_speed * delta
	position += move_speed * delta

	move_and_slide()
