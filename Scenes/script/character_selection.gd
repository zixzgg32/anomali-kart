extends Control

@export var character_names: Array[String] = ["Character 1", "Character 2", "Character 3", "Character 4"]
@export var character_sprites: Array[NodePath] = [
	"Character1",
	"Character2",
	"Character3",
	"Character4"
]
@export var navigation_sound: AudioStream
@export var selection_sound: AudioStream
# Nama tombol sebagai string
@export var left_button_name: String = "LeftButton"
@export var right_button_name: String = "RightButton"

var current_index: int = 0
var audio_player: AudioStreamPlayer
var left_button: Button
var right_button: Button

func _ready():
	# Inisialisasi AudioStreamPlayer
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	# Mencari tombol berdasarkan nama
	left_button = get_node_or_null(left_button_name) as Button
	right_button = get_node_or_null(right_button_name) as Button
	
	# Hubungkan sinyal jika tombol ditemukan
	if left_button:
		left_button.pressed.connect(_on_left_button_pressed)
	else:
		printerr("Left button not found with name:", left_button_name)
	
	if right_button:
		right_button.pressed.connect(_on_right_button_pressed)
	else:
		printerr("Right button not found with name:", right_button_name)
	
	# Inisialisasi karakter
	for i in range(character_sprites.size()):
		var sprite = get_node_or_null(character_sprites[i])
		if sprite == null:
			print("Error: Node not found for path:", character_sprites[i])
	$Label.text = character_names[current_index]
	update_selection()

func _input(event):
	if event.is_action_pressed("ui_left"):
		navigate_left()
	elif event.is_action_pressed("ui_right"):
		navigate_right()
	elif event.is_action_pressed("ui_accept"):
		confirm_selection()

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
	for i in range(character_sprites.size()):
		var sprite = get_node_or_null(character_sprites[i])
		if sprite:
			sprite.visible = (i == current_index)
			if i == current_index:
				var center = get_viewport_rect().size / 2
				sprite.position = center - sprite.size / 2
	$Label.text = character_names[current_index]
	
func confirm_selection():
	play_sound(selection_sound)
	Globals.selected_character_index = current_index
	get_tree().change_scene_to_file("res://Scenes/trackSelection.tscn")
	
func go_back():
	play_sound(navigation_sound)
	get_tree().change_scene_to_file("res://Scenes/mainMenu.tscn")
