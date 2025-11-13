extends CharacterBody3D

var original_position: Vector3
var tween: Tween
var shake_range := 0.015
var shake_time := 0.5
var shake_duration := 0.06
var shake_timer := 0.0

func _physics_process(delta: float) -> void:

	if shake_timer > 0:
		shake()
		shake_timer -= delta

	move_and_slide()

func catched() -> void:
	$CollisionShape3D.disabled = true
	collision_layer = 0
	collision_mask = 0
	original_position = position
	shake_timer = shake_time

func shake():
	if tween and tween.is_running():
		return
		
	tween = create_tween()
	var offset = Vector3(randf_range(1, 1), randf_range(-1, 1), randf_range(-1, 1)) * shake_range
	tween.tween_property(self, "position", original_position + offset, shake_duration)
	tween.tween_property(self, "position", original_position, shake_duration)
