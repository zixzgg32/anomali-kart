extends Control

@export var character_names: Array[String] = ["Character 1", "Character 2", "Character 3", "Character 4"]
@export var character_sprites: Array[NodePath] = [
	"Character1",
	"Character2",
	"Character3",
	"Character4"
]
@export var bgm: AudioStream
@export var navigation_sound: AudioStream
@export var selection_sound: AudioStream
@export var bgm_volume: float = -10.0
@export var left_button_name: String = "LeftButton"
@export var right_button_name: String = "RightButton"
@export var player1_label: Label
@export var player2_label: Label

var bgm_player: AudioStreamPlayer
var current_index: int = 0
var audio_player: AudioStreamPlayer
var left_button: Button
var right_button: Button
var is_player2_selection: bool = false
var player1_selected_index: int = -1

func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	if bgm:
		bgm_player.stream = bgm
		bgm_player.volume_db = bgm_volume
		bgm_player.play()
	
	left_button = get_node_or_null(left_button_name) as Button
	right_button = get_node_or_null(right_button_name) as Button
	
	if left_button:
		left_button.pressed.connect(_on_left_button_pressed)
	else:
		printerr("Left button not found with name:", left_button_name)
	
	if right_button:
		right_button.pressed.connect(_on_right_button_pressed)
	else:
		printerr("Right button not found with name:", right_button_name)
	
	# Initialize labels
	if player1_label:
		player1_label.visible = true
	if player2_label:
		player2_label.visible = false
	
	update_selection()

func _input(event):
	if event.is_action_pressed("ui_left"):
		navigate_left()
	elif event.is_action_pressed("ui_right"):
		navigate_right()
	elif event.is_action_pressed("ui_accept"):
		confirm_selection()
	elif event.is_action_pressed("ui_cancel"):
		go_back()

func _on_left_button_pressed():
	navigate_left()

func _on_right_button_pressed():
	navigate_right()

func navigate_left():
	play_sound(navigation_sound)
	current_index = (current_index - 1 + character_sprites.size()) % character_sprites.size()
	update_selection()

func navigate_right():
	play_sound(navigation_sound)
	current_index = (current_index + 1) % character_sprites.size()
	update_selection()

func play_sound(sound: AudioStream):
	if sound and audio_player:
		audio_player.stream = sound
		audio_player.play()

func update_selection():
	# Show only the current character
	for i in range(character_sprites.size()):
		var sprite = get_node_or_null(character_sprites[i])
		if sprite:
			sprite.visible = (i == current_index)
			if i == current_index:
				var center = get_viewport_rect().size / 2
				sprite.position = center - sprite.size / 2
	
	# Update label based on current player
	if is_player2_selection:
		$Label.text = "Player 2: " + character_names[current_index]
	else:
		$Label.text = "Player 1: " + character_names[current_index]

func confirm_selection():
	play_sound(selection_sound)
	
	if !is_player2_selection:
		# Player 1 confirms their selection
		player1_selected_index = current_index
		
		# Switch to player 2 selection
		is_player2_selection = true
		current_index = 0  # Reset selection index for player 2
		
		# Update labels
		if player1_label:
			player1_label.visible = false
		if player2_label:
			player2_label.visible = true
		
		update_selection()
	else:
		# Player 2 confirms, proceed to track selection
		fade_out_bgm()
		Globals.player1_selection = player1_selected_index
		Globals.player2_selection = current_index
		get_tree().change_scene_to_file("res://Scenes/multiplayer2track.tscn")

func go_back():
	if is_player2_selection:
		# Go back to player 1 selection
		is_player2_selection = false
		if player1_label:
			player1_label.visible = true
		if player2_label:
			player2_label.visible = false
		current_index = player1_selected_index
		update_selection()
	else:
		# Go back to main menu
		play_sound(navigation_sound)
		get_tree().change_scene_to_file("res://Scenes/mainMenu.tscn")
	
func fade_out_bgm(duration: float = 0.5):
	var tween = create_tween()
	tween.tween_property(bgm_player, "volume_db", -80.0, duration)
	await tween.finished
	bgm_player.stop()
	bgm_player.volume_db = bgm_volume
