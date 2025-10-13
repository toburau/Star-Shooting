extends Node3D
@export var meteor_scene: PackedScene
@export var spawn_count := 100
@export var spawn_area_size := Vector3(50, 50, 50)  # 配置範囲

var spawned_objects: Array = []  # ここに生成したノードを記録しておく

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	spawn_objects()

func spawn_meteor():
	if meteor_scene == null:
		return
	
	var meteor = meteor_scene.instantiate()
	
	var x = randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2)
	var y = randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
	var z = randf_range(-spawn_area_size.z / 2, spawn_area_size.z / 2)
	meteor.position = Vector3(x,y,z)
	meteor.rotation_degrees = Vector3(
		randf_range(0, 360),
		randf_range(0, 360),
		randf_range(0, 360)
	)	
	add_child(meteor)
	spawned_objects.append(meteor)

func spawn_objects():
	for i in range(spawn_count):
		spawn_meteor()
	
func clear_objects():
	for obj in spawned_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	spawned_objects.clear()	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_pressed("debug_1"):
		clear_objects()
		spawn_objects()
