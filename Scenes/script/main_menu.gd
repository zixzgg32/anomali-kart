extends Control

@export var fade_duration: float = 1.0
@export var click_sound: AudioStream
@export var bgm: AudioStream
@export var bgm_volume: float = -10.0

var audio_player: AudioStreamPlayer
var bgm_player: AudioStreamPlayer

func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	if click_sound:
		audio_player.stream = click_sound
	
	
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	
	if bgm:
		bgm_player.stream = bgm
		bgm_player.volume_db = bgm_volume
		bgm_player.play()
	
	
	modulate = Color(1, 1, 1, 0)
	fade_in()
	
	
	$VBoxContainer/"Single Player".pressed.connect(_on_single_player_pressed)
	$VBoxContainer/"Multiplayer".pressed.connect(_on_multiplayer_pressed)
	$VBoxContainer/"Settings".pressed.connect(_on_settings_pressed)
	$VBoxContainer/"Exit".pressed.connect(_on_exit_pressed)

func play_click_sound():
	if audio_player and audio_player.stream:
		audio_player.play()

func fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)

func set_bgm_volume(volume: float):
	if bgm_player:
		bgm_player.volume_db = volume

func stop_bgm():
	if bgm_player:
		bgm_player.stop()

func play_bgm():
	if bgm_player and bgm_player.stream and not bgm_player.playing:
		bgm_player.play()

func _on_single_player_pressed():
	play_click_sound()
	print("Single Player button pressed")
	stop_bgm()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Scenes/characterSelection.tscn")

func _on_multiplayer_pressed():
	play_click_sound()
	print("Multiplayer button pressed")
	stop_bgm()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Scenes/trackSelection.tscn")

func _on_settings_pressed():
	play_click_sound()
	print("Loading settings scene...")
	var scene = load("res://Scenes/tester.tscn")
	if scene:
		print("Scene loaded successfully")
		stop_bgm()
		await get_tree().create_timer(0.2).timeout
		get_tree().change_scene_to_packed(scene)
	else:
		print("Failed to load scene")


func _on_exit_pressed():
	play_click_sound()
	print("Exit button pressed")
	stop_bgm()
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
