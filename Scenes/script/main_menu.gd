extends Control

@export var fade_duration: float = 1.0

func _ready():
	# Mulai dengan transparansi penuh
	modulate = Color(1, 1, 1, 0)
	fade_in()

	# Hubungkan tombol ke fungsi masing-masing
	$VBoxContainer/"Single Player".pressed.connect(_on_single_player_pressed)
	$VBoxContainer/"Multiplayer".pressed.connect(_on_multiplayer_pressed)
	$VBoxContainer/"Settings".pressed.connect(_on_settings_pressed)
	$VBoxContainer/"Exit".pressed.connect(_on_exit_pressed)

func fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)

func _on_single_player_pressed():
	# Logika untuk tombol Single Player
	print("Single Player button pressed")
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_multiplayer_pressed():
	# Logika untuk tombol Multiplayer
	print("Multiplayer button pressed")
	get_tree().change_scene_to_file("res://Scenes/trackSelection.tscn")

func _on_settings_pressed():
	# Logika untuk tombol Settings
	print("Settings button pressed")
	get_tree().change_scene_to_file("res://Scenes/settings.tscn")

func _on_exit_pressed():
	# Logika untuk tombol Exit
	print("Exit button pressed")
	get_tree().quit()
