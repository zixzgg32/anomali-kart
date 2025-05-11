extends Control

@export var next_scene: PackedScene
@export var fade_duration: float = 1.0
@export var display_time: float = 2.0

func _ready():
	# Mulai dengan transparansi penuh
	modulate = Color(1, 1, 1, 0)
	fade_in()

func fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)
	tween.finished.connect(fade_out)

func fade_out():
	await get_tree().create_timer(display_time).timeout
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.finished.connect(change_scene)

func change_scene():
	get_tree().change_scene_to_packed(next_scene)
