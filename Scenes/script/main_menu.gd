extends Control

@export var fade_duration: float = 1.0
@export var click_sound: AudioStream # Biarkan ini kosong di inspector dan assign file suara Anda

var audio_player: AudioStreamPlayer

func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	if click_sound:
		audio_player.stream = click_sound
	
	# Mulai dengan transparansi penuh
	modulate = Color(1, 1, 1, 0)
	fade_in()

	# Hubungkan tombol ke fungsi masing-masing
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

func _on_single_player_pressed():
	play_click_sound()
	# Logika untuk tombol Single Player
	print("Single Player button pressed")
	await get_tree().create_timer(0.2).timeout # Tunggu sedikit agar suara terdengar
	get_tree().change_scene_to_file("res://Scenes/characterSelection.tscn")

func _on_multiplayer_pressed():
	play_click_sound()
	# Logika untuk tombol Multiplayer
	print("Multiplayer button pressed")
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Scenes/trackSelection.tscn")

func _on_settings_pressed():
	play_click_sound()
	# Logika untuk tombol Settings
	print("Settings button pressed")
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")

func _on_exit_pressed():
	play_click_sound()
	# Logika untuk tombol Exit
	print("Exit button pressed")
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()
