extends Control

@export var track_names: Array[String] = ["Track 1", "Track 2", "Track 3", "Track 4"]
@export var track_sprites: Array[NodePath] = [
	"Track1",
	"Track2",
	"Track3",
	"Track4"
]
@export var bgm: AudioStream
@export var navigation_sound: AudioStream
@export var selection_sound: AudioStream
@export var left_button_name: String = "LeftButton"
@export var right_button_name: String = "RightButton"
@export var bgm_volume: float = -10.0

var current_index: int = 0
var audio_player: AudioStreamPlayer
var left_button: Button
var right_button: Button
var back_button: Button
var bgm_player: AudioStreamPlayer

func _ready():
	# Initialize audio player
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	if bgm:
		bgm_player.stream = bgm
		bgm_player.volume_db = bgm_volume
		bgm_player.play()
		
	# Setup buttons
	setup_buttons()
	
	# Initialize tracks
	initialize_tracks()
	
	update_selection()



func setup_buttons():
	left_button = get_node_or_null(left_button_name) as Button
	right_button = get_node_or_null(right_button_name) as Button
	
	if left_button:
		left_button.pressed.connect(navigate_left)
	else:
		printerr("Left button not found with name:", left_button_name)
	
	if right_button:
		right_button.pressed.connect(navigate_right)
	else:
		printerr("Right button not found with name:", right_button_name)
		

func initialize_tracks():
	for i in range(track_sprites.size()):
		var sprite = get_node_or_null(track_sprites[i])
		if sprite == null:
			printerr("Track sprite not found for path:", track_sprites[i])
		else:
			sprite.visible = false
	$Label.text = track_names[current_index]

func _input(event):
	if event.is_action_pressed("ui_left"):
		navigate_left()
	elif event.is_action_pressed("ui_right"):
		navigate_right()
	elif event.is_action_pressed("ui_accept"):
		confirm_selection()
	elif event.is_action_pressed("ui_cancel"):
		go_back()

func navigate_left():
	play_sound(navigation_sound)
	current_index = (current_index - 1 + track_sprites.size()) % track_sprites.size()
	update_selection()

func navigate_right():
	play_sound(navigation_sound)
	current_index = (current_index + 1) % track_sprites.size()
	update_selection()

func play_sound(sound: AudioStream):
	if sound and audio_player:
		audio_player.stream = sound
		audio_player.play()

func update_selection():
	for i in range(track_sprites.size()):
		var sprite = get_node_or_null(track_sprites[i])
		if sprite == null:
			printerr("Track sprite not found for path:", track_sprites[i])
			continue
		sprite.visible = (i == current_index)
		if i == current_index:
			# Hitung ukuran visual setelah scaling
			var screen_size = Vector2(640, 360)
			var visual_size = sprite.size * sprite.scale
			sprite.position = (screen_size - visual_size) / 2
			print("Sprite position:", sprite.position)
			print("Selected track:", track_names[i])
	$Label.text = track_names[current_index]

func confirm_selection():
	play_sound(selection_sound)
	fade_out_bgm()
	Globals.selected_track_index = current_index
	print("Track selected: ", track_names[current_index])
	get_tree().change_scene_to_file("res://Scenes/multiplayer.tscn")

func go_back():
	play_sound(navigation_sound)
	get_tree().change_scene_to_file("res://Scenes/multiplayerselect.tscn")

func fade_out_bgm(duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(bgm_player, "volume_db", -80.0, duration)
	await tween.finished
	bgm_player.stop()
	bgm_player.volume_db = bgm_volume  
