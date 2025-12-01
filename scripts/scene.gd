extends Node3D
@export var meteor_scene: PackedScene
@export var debris_scene: PackedScene
@export var spawn_meteor_count := 100
@export var spawn_area_size := Vector3(50, 50, 50)  # 配置範囲
@export var spawn_debris_count := 10

const LIFE_IMAGE = preload("res://images/shield_bronze.png")

var spawned_objects: Array = []  # ここに生成したノードを記録しておく
var clear_flag = false
var life_objects: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize()
	spawn_objects()
	$CanvasLayer/Control/RadarDots.add_targets()
	$CanvasLayer/ClearText.modulate.a = 0
	
	# life icon
	var viewport_size: Vector2 = $CanvasLayer.get_viewport().size	
	for i in $Player.life:
		var sprite = Sprite2D.new()
		sprite.texture = LIFE_IMAGE
		sprite.position = Vector2(viewport_size.x - 40 - i * 36, 20)
		$CanvasLayer.add_child(sprite)
		life_objects.append(sprite)

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

func clear_scene():
	$AudioStreamPlayer.play()
	$CanvasLayer/ClearText.modulate.a = 1.0
	await get_tree().create_timer(3.0).timeout
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	var debris = get_tree().get_nodes_in_group("debris").size()
	$CanvasLayer/Label.text = "Debris: %d" % debris 

	if debris == 0 and clear_flag == false:
		clear_flag = true
		await get_tree().create_timer(1.0).timeout
		clear_scene()

	if Input.is_action_pressed("debug_1"):
		clear_objects()
		#spawn_objects()
