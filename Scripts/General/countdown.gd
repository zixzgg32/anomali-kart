extends Node2D

@onready var label: Label = $Label
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

signal countdown_finished

func _ready():
	label.hide()
	start_countdown()

func start_countdown():
	var countdown_numbers = ["3", "2", "1", "GO!"]
	var countdown_sound = preload("res://Asset/sound/soundeffect/soundeffect/countdown.wav")
	
	
	audio_player.stop()  
	audio_player.stream = countdown_sound
	
	for number in countdown_numbers:
		label.text = number
		label.show()
		
		
		audio_player.pitch_scale = 1.0
		
		
		if not audio_player.playing:
			audio_player.play()
		
		
		var tween = create_tween()
		if number == "GO!":
			tween.tween_property(label, "scale", Vector2(1.5, 1.5), 0.2)
			tween.tween_property(label, "modulate", Color(0, 1, 0), 0.2)
		else:
			tween.tween_property(label, "scale", Vector2(1.3, 1.3), 0.2)
		tween.tween_property(label, "scale", Vector2(1, 1), 0.2)
		
		
		await get_tree().create_timer(0.7).timeout  
		
		label.hide()
	
	emit_signal("countdown_finished")
	queue_free()
