extends Node2D

@onready var label: Label = $Label
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

signal countdown_finished

func _ready():
	label.hide()
	label.size = Vector2(200, 200)  
	start_countdown()

func start_countdown():
	var countdown_numbers = ["3", "2", "1", "GO!"]
	var countdown_sound = preload("res://Asset/sound/soundeffect/soundeffect/countdown_1_1.wav")
	var tick_sound = preload("res://Asset/sound/soundeffect/soundeffect/countdown.wav")  
	audio_player.stream = countdown_sound
	for number in countdown_numbers:
		if number != "GO!":
			for i in range(5):  
				var random_num = str(randi() % 9 + 1) 
				label.text = random_num
				label.show()
				audio_player.stream = tick_sound
				audio_player.pitch_scale = 2.0 + i * 0.3  
				audio_player.play()
				
				var quick_tween = create_tween()
				quick_tween.tween_property(label, "scale", Vector2(1.1, 1.1), 0.05)
				quick_tween.tween_property(label, "scale", Vector2(1, 1), 0.05)
				
				await get_tree().create_timer(0.1 - i * 0.015).timeout  
				audio_player.stop()
		
		label.text = number
		label.show() 
		var move_tween = create_tween()
		if number == "GO!": 
			for i in range(5):   
				var random_num = str(randi() % 9 + 1) 
				label.text = random_num
				label.show()
				audio_player.stream = tick_sound
				audio_player.pitch_scale = 2.0 + i * 0.3  
				audio_player.play()
				var quick_tween = create_tween()
				move_tween.tween_property(label, "position", Vector2(300, 128), 0.2)
				quick_tween.tween_property(label, "scale", Vector2(1.1, 1.1), 0.05)
				quick_tween.tween_property(label, "scale", Vector2(1, 1), 0.05)
				await get_tree().create_timer(0.1 - i * 0.015).timeout
				audio_player.stop()
			label.text = number
			label.show()
			audio_player.stream = countdown_sound
			audio_player.play()
			var go_tween = create_tween()
			go_tween.set_parallel(true)
			go_tween.tween_property(label, "scale", Vector2(2.5, 2.5), 0.3).set_trans(Tween.TRANS_BACK)
			go_tween.tween_property(label, "modulate", Color(0, 1, 0), 0.3)
			go_tween.tween_property(label, "rotation", deg_to_rad(10), 0.2)
			go_tween.tween_property(label, "rotation", deg_to_rad(-10), 0.2).set_delay(0.2)
			go_tween.tween_property(label, "rotation", 0, 0.2).set_delay(0.4)
			await get_tree().create_timer(0.3).timeout
			
			var blink_tween = create_tween()
			blink_tween.tween_property(label, "modulate:a", 0.5, 0.1)
			blink_tween.tween_property(label, "modulate:a", 1.0, 0.1)
			blink_tween.set_loops(3)
		else:
			audio_player.pitch_scale = 1.0
			audio_player.play()
			
			var num_tween = create_tween()
			num_tween.set_parallel(true)
			num_tween.tween_property(label, "scale", Vector2(1.8, 1.8), 0.2).set_trans(Tween.TRANS_BOUNCE)
			num_tween.tween_property(label, "modulate", Color(1, 0.5, 0.5), 0.1)
			num_tween.tween_property(label, "modulate", Color(1, 1, 1), 0.1).set_delay(0.1)
		
		await get_tree().create_timer(0.7 if number != "GO!" else 1.7).timeout
		label.hide()
	
	emit_signal("countdown_finished")
	queue_free()
