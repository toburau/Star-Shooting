extends CharacterBody3D

func _physics_process(delta: float) -> void:
	move_and_slide()

func catched() -> void:
	$CollisionShape3D.disabled = true
	collision_layer = 0
	collision_mask = 0
