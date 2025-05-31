extends Control

@export var fade_duration: float = 1.0
@export var click_sound: AudioStream
@export var bgm: AudioStream
@onready var bgm_slider = $VBoxContainer2/BGMSlider
@onready var se_slider = $VBoxContainer2/SESlider
@onready var bgm_label: Label = $ColorRect/BGMLabel
@onready var se_label: Label = $ColorRect/SELabel

var audio_player: AudioStreamPlayer
var bgm_player: AudioStreamPlayer


func _on_bgm_volume_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("BGM"), value)
	bgm_label.text = "%.1f dB" % value


func _on_se_volume_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SE"), value)
	se_label.text = "%.1f dB" % value

func _ready():
	if Settings.load() != OK:
		Settings.bgm_volume = -10.0
		Settings.se_volume = -10.0
	bgm_slider.value_changed.connect(_on_bgm_volume_changed)
	se_slider.value_changed.connect(_on_se_volume_changed)
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	if click_sound:
		audio_player.stream = click_sound
	
	# Setup BGM
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	if bgm:
		bgm_player.stream = bgm
		bgm_player.volume_db = Settings.bgm_volume
		bgm_player.play()
	
	# Set slider values
	bgm_slider.value = Settings.bgm_volume
	se_slider.value = Settings.se_volume
	
	# Fade in effect
	modulate = Color(1, 1, 1, 0)
	
	$ColorRect/Button.pressed.connect(_on_exit_pressed)

func fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)

func _on_BGMSlider_value_changed(value):
	Settings.bgm_volume = value
	bgm_player.volume_db = value
	Settings.save()

func _on_SESlider_value_changed(value):
	Settings.se_volume = value
	audio_player.volume_db = value
	Settings.save()

func play_click_sound():
	if audio_player and audio_player.stream:
		audio_player.play()

func _on_exit_pressed():
	play_click_sound()
	stop_bgm()
	get_tree().change_scene_to_file("res://Scenes/mainMenu.tscn") 

func stop_bgm():
	if bgm_player:
		bgm_player.stop()
