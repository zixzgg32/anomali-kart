extends Control

@export var next_scene: String = "res://Scenes/mainMenu.tscn"
@onready var skip_label1 = $SKIP  
@onready var skip_label2 = $SKIP2
@onready var subtitle_panel = $SubtitlePanel
@onready var subtitle_label = $SubtitlePanel/SubtitleLabel

var scene_groups := [
	{ 
		"name": "scene1", 
		"sound_path": "res://Asset/sound/scene1fix.mp3",
		"subtitles": [
			{"time": 0.0, "text": "Di  ujung dunia, tersembunyi dibalik kabut waktu"},
			{"time": 3.0, "text": "Berdirilah sebuah kota yang telah lama ditinggalkan"},
			{"time": 6.0, "text": "Namun, suatu hari ada anomali anomali mulai bermunculan"},
			{"time": 10.0, "text": "Tung Tung Tung Sahur, Ballerina Cappuccina"},
			{"time": 13.0, "text": "Tralalero Tralala dan Asssasino Cappuccino"},
			{"time": 16.0, "text": "Mereka Datang Tanpa Peringatan"},
			{"time": 18.0, "text": "Membawa kekuatan misterius yang mengganggu keseimbangan dunia"},
			{"time": 21.0, "text": "Memicu Ketegangan yang tak terhindarkan"}
		]
	},
	{ 
		"name": "scene2", 
		"sound_path": "res://Asset/sound/scene2.mp3",
		"subtitles": [
			{"time": 0.0, "text": "Masing Masing merasa dirinya yang terkuat, Paling layak memimpin"},
			{"time": 3.0, "text": "Dengan ambisi membara, persaingan semakin sengit"},
			{"time": 5.0, "text": "Dunia pun terancam pecah, berada di ambang kehancuran"},
		
		]
	},
	{ 
		"name": "scene3", 
		"sound_path": "res://Asset/sound/scene3.mp3",
		"subtitles": [
			{"time": 0.0, "text": "Saat kekacauan nyaris pecah, Dewa semesta turun tangan."},
			{"time": 2.0, "text": "Ia mengumpulkan para anomali anomali tersebut dan menetapkan satu cara"},
			{"time": 6.0, "text": "untuk menentukan pemimpin"},
			{"time": 8.0, "text": "Turnamen Balapan."},
			{"time": 11.0, "text": "Satu pemenang, satu takhta. Beginilah takdir ditentukan, di lintasan para legenda"},
			{"time": 15.0, "text": "Para anomali pun siap bertanding!"},
		]
	}
]

var current_group_index: int = 0
var current_texture_index: int = 0
var current_subtitle_index: int = 0
var timer: Timer
var subtitle_timer: Timer
var texture_durations := [] 
var audio_player: AudioStreamPlayer

func _ready():
	setup_subtitle_system()
	calculate_texture_durations()
	show_group(current_group_index)
	show_texture_in_group(current_group_index, 0)
	play_group_sound(current_group_index)
	start_texture_timer(current_group_index, 0)
	start_subtitle_system(current_group_index)
	
func _input(event):
	if event.is_action_pressed("ui_select") or event.is_action_pressed("ui_accept") or (event is InputEventKey and event.keycode == KEY_SPACE):
		cleanup_timers()
		if skip_label1:
			skip_label1.visible = false
		if skip_label2:
			skip_label2.visible = false
		get_tree().change_scene_to_file(next_scene)

func setup_subtitle_system():
	if not subtitle_panel:
		subtitle_panel = Panel.new()
		subtitle_panel.name = "SubtitlePanel"
		
		subtitle_panel.anchors_preset = Control.PRESET_BOTTOM_WIDE
		subtitle_panel.offset_left = 50
		subtitle_panel.offset_right = -50
		subtitle_panel.offset_top = -80
		subtitle_panel.offset_bottom = -10
		
		subtitle_panel.modulate = Color(1, 1, 1, 0)
		add_child(subtitle_panel)
		
		subtitle_label = Label.new()
		subtitle_label.name = "SubtitleLabel"
		subtitle_label.anchors_preset = Control.PRESET_FULL_RECT
		subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		subtitle_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		subtitle_label.add_theme_constant_override("shadow_offset_x", 2)
		subtitle_label.add_theme_constant_override("shadow_offset_y", 2)
		subtitle_panel.add_child(subtitle_label)
	
	subtitle_panel.visible = false

func start_subtitle_system(group_idx: int):
	current_subtitle_index = 0
	schedule_next_subtitle(group_idx)

func schedule_next_subtitle(group_idx: int):
	if subtitle_timer:
		subtitle_timer.queue_free()
	
	var subtitles = scene_groups[group_idx].get("subtitles", [])
	if current_subtitle_index >= subtitles.size():
		return
	
	subtitle_timer = Timer.new()
	var subtitle_data = subtitles[current_subtitle_index]
	subtitle_timer.wait_time = subtitle_data["time"] if current_subtitle_index == 0 else (subtitle_data["time"] - subtitles[current_subtitle_index - 1]["time"])
	subtitle_timer.one_shot = true
	subtitle_timer.timeout.connect(_on_subtitle_timer_timeout.bind(group_idx))
	add_child(subtitle_timer)
	subtitle_timer.start()

func _on_subtitle_timer_timeout(group_idx: int):
	var subtitles = scene_groups[group_idx].get("subtitles", [])
	if current_subtitle_index < subtitles.size():
		show_subtitle(subtitles[current_subtitle_index]["text"])
		current_subtitle_index += 1
		schedule_next_subtitle(group_idx)

func show_subtitle(text: String):
	if subtitle_label:
		subtitle_label.text = text
		subtitle_panel.visible = true
		
		var tween = create_tween()
		subtitle_label.modulate.a = 0.0
		tween.tween_property(subtitle_label, "modulate:a", 1.0, 0.3)

func hide_subtitle():
	if subtitle_panel:
		var tween = create_tween()
		tween.tween_property(subtitle_label, "modulate:a", 0.0, 0.3)
		tween.tween_callback(func(): subtitle_panel.visible = false)

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
		hide_subtitle()
		hide_group(current_group_index)
		current_group_index += 1
		current_texture_index = 0
		if current_group_index >= scene_groups.size():
			cleanup_timers()
			if skip_label1:
				skip_label1.visible = false
			if skip_label2:
				skip_label2.visible = false
			get_tree().change_scene_to_file(next_scene)
		else:
			show_group(current_group_index)
			show_texture_in_group(current_group_index, 0)
			play_group_sound(current_group_index)
			start_texture_timer(current_group_index, 0)
			start_subtitle_system(current_group_index)
	else:
		show_texture_in_group(current_group_index, current_texture_index)
		start_texture_timer(current_group_index, current_texture_index)

func cleanup_timers():
	if timer:
		timer.queue_free()
		timer = null
	if subtitle_timer:
		subtitle_timer.queue_free()
		subtitle_timer = null
	if audio_player:
		audio_player.stop()
		audio_player.queue_free()
		audio_player = null

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
			if i == texture_idx:
				texture_rects[i].visible = true
				var tween = create_tween()
				texture_rects[i].modulate.a = 0.0
				tween.tween_property(texture_rects[i], "modulate:a", 1.0, 0.5)
			else:
				if texture_rects[i].visible and texture_rects[i].modulate.a > 0.0:
					var tween = create_tween()
					tween.tween_property(texture_rects[i], "modulate:a", 0.0, 0.5)
					tween.tween_callback(Callable(texture_rects[i], "hide"))
				else:
					texture_rects[i].visible = false
					texture_rects[i].modulate.a = 0.0
