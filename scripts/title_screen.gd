extends Control

var initialized = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/ButtonStart.grab_focus()
	await get_tree().process_frame
	initialized = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_start_pressed() -> void:
	$AudioStreamPlayer.stream = preload("res://sound/accept.mp3")
	$AudioStreamPlayer.play()
	await $AudioStreamPlayer.finished
	get_tree().change_scene_to_file("res://scenes/scene.tscn")


func _on_button_exit_pressed() -> void:
	$AudioStreamPlayer.stream = preload("res://sound/accept.mp3")
	$AudioStreamPlayer.play()
	await $AudioStreamPlayer.finished
	get_tree().quit()

func _on_button_start_focus_entered() -> void:
	if not initialized:
		return
	$AudioStreamPlayer.stream = preload("res://sound/cursor.mp3")
	$AudioStreamPlayer.play()

func _on_button_exit_focus_entered() -> void:
	if not initialized:
		return
	$AudioStreamPlayer.stream = preload("res://sound/cursor.mp3")
	$AudioStreamPlayer.play()
