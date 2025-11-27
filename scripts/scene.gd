extends Node3D
@export var meteor_scene: PackedScene
@export var debris_scene: PackedScene
@export var spawn_meteor_count := 100
@export var spawn_area_size := Vector3(50, 50, 50)  # 配置範囲
@export var spawn_debris_count := 1

var spawned_objects: Array = []  # ここに生成したノードを記録しておく

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	spawn_objects()
	$CanvasLayer/Control/RadarDots.add_targets()
	$CanvasLayer/ClearText.modulate.a = 0

func spawn_object(scene: PackedScene):
	if scene == null:
		return
	
	var object = scene.instantiate()
	
	var x = randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2)
	var y = randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
	var z = randf_range(-spawn_area_size.z / 2, spawn_area_size.z / 2)
	object.position = Vector3(x,y,z)
	object.rotation_degrees = Vector3(
		randf_range(0, 360),
		randf_range(0, 360),
		randf_range(0, 360)
	)	
	add_child(object)
	spawned_objects.append(object)

func spawn_objects():
	for i in range(spawn_meteor_count):
		spawn_object(meteor_scene)
	for i in range(spawn_debris_count):
		spawn_object(debris_scene)
	
func clear_objects():
	for obj in spawned_objects:
		if is_instance_valid(obj):
			obj.queue_free()
	spawned_objects.clear()	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	var debris = get_tree().get_nodes_in_group("debris").size()
	$CanvasLayer/Label.text = "Debris: %d" % debris 

	if debris == 0:
		$CanvasLayer/ClearText.modulate.a = 1.0

	if Input.is_action_pressed("debug_1"):
		#clear_objects()
		#spawn_objects()
		var camera = get_viewport().get_camera_3d()
		if camera:
			camera.shake(1.0)
