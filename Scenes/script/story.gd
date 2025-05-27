extends Control

@export var next_scene: String = "res://Scenes/mainMenu.tscn"

# Tambahkan path sound untuk setiap grup
var scene_groups := [
	{ "name": "scene1", "sound_path": "res://Asset/sound/scene1fix.mp3" },
	{ "name": "scene2", "sound_path": "res://Asset/sound/scene2.mp3" },
	{ "name": "scene3", "sound_path": "res://Asset/sound/scene3.mp3" }
]

var current_group_index: int = 0
var current_texture_index: int = 0
var timer: Timer
var texture_durations := [] # Akan diisi otomatis
var audio_player: AudioStreamPlayer

func _ready():
	calculate_texture_durations()
	show_group(current_group_index)
	show_texture_in_group(current_group_index, 0)
	play_group_sound(current_group_index)
	start_texture_timer(current_group_index, 0)
	
func _input(event):
	if event.is_action_pressed("ui_select") or event.is_action_pressed("ui_accept") or (event is InputEventKey and event.keycode == KEY_SPACE):
		get_tree().change_scene_to_file(next_scene)

func calculate_texture_durations():
	texture_durations.clear()
	for group in scene_groups:
		var sound = load(group["sound_path"])
		var duration = 1.0
		if sound and sound is AudioStream:
			duration = sound.get_length()
		group["duration"] = duration
		var group_node = get_node_or_null(group["name"])
		if group_node:
			var count = 0
			for child in group_node.get_children():
				if child is TextureRect:
					count += 1
			var per_tex = 0.0
			if count > 0:
				per_tex = group["duration"] / float(count)
			var durations = []
			for i in range(count):
				durations.append(per_tex)
			texture_durations.append(durations)
		else:
			texture_durations.append([])

func play_group_sound(group_idx: int):
	if audio_player:
		audio_player.stop()
		audio_player.queue_free()
	audio_player = AudioStreamPlayer.new()
	var sound = load(scene_groups[group_idx]["sound_path"])
	audio_player.stream = sound
	add_child(audio_player)
	audio_player.play()

func start_texture_timer(group_idx: int, texture_idx: int):
	if timer:
		timer.queue_free()
	timer = Timer.new()
	var durations = texture_durations[group_idx]
	timer.wait_time = durations[texture_idx]
	timer.one_shot = true
	timer.timeout.connect(_on_texture_timer_timeout)
	add_child(timer)
	timer.start()

func _on_texture_timer_timeout():
	var textures_count = texture_durations[current_group_index].size()
	current_texture_index += 1
	if current_texture_index >= textures_count:
		hide_group(current_group_index)
		current_group_index += 1
		current_texture_index = 0
		if current_group_index >= scene_groups.size():
			get_tree().change_scene_to_file(next_scene)
		else:
			show_group(current_group_index)
			show_texture_in_group(current_group_index, 0)
			play_group_sound(current_group_index)
			start_texture_timer(current_group_index, 0)
	else:
		show_texture_in_group(current_group_index, current_texture_index)
		start_texture_timer(current_group_index, current_texture_index)

func show_group(index: int):
	for i in range(scene_groups.size()):
		var group_node = get_node_or_null(scene_groups[i]["name"])
		if group_node:
			group_node.visible = (i == index)

func hide_group(index: int):
	var group_node = get_node_or_null(scene_groups[index]["name"])
	if group_node:
		group_node.visible = false

func show_texture_in_group(group_idx: int, texture_idx: int):
	var group_node = get_node_or_null(scene_groups[group_idx]["name"])
	if group_node:
		var texture_rects = []
		for child in group_node.get_children():
			if child is TextureRect:
				texture_rects.append(child)
		for i in range(texture_rects.size()):
			texture_rects[i].visible = (i == texture_idx)
