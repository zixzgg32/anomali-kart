# WinningSceneController.gd
extends Control

@onready var scene_display: TextureRect = $SceneDisplay
@onready var timer: Timer = $Timer

var scene_paths := [
	"res://Asset/Animasi END/1-scene.png",
	"res://Asset/Animasi END/stairs-scene1.png", 
	"res://Asset/Animasi END/stairs-scene2.png",
	"res://Asset/Animasi END/stairs-scene3.png"
]

var character_names := ["tts", "ballerina", "assasino", "tralalero"]
var current_scene_index := 0
var race_results := []
var fallback_texture: ImageTexture
var is_playing_scene := false

signal winning_scene_finished

func _ready():
	hide()
	
	# Create fallback black texture
	var image = Image.create(640, 360, false, Image.FORMAT_RGB8)
	image.fill(Color.BLACK)
	fallback_texture = ImageTexture.new()
	fallback_texture.set_image(image)
	
	# Setup timer properly
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	
	print("WinningSceneController ready")

func play_winning_scene(results: Array):
	if is_playing_scene:
		return
		
	print("Starting winning scene with results: ", results)
	race_results = results
	current_scene_index = 0
	is_playing_scene = true
	show()
	
	# Wait a frame to ensure everything is ready
	await get_tree().process_frame
	_show_next_scene()

func _show_next_scene():
	if !is_playing_scene:
		return
		
	print("Showing scene ", current_scene_index)
	
	var texture_to_load: Texture2D
	
	if current_scene_index < 4:
		# Load basic scenes (1-scene, stairs-scene1, etc.)
		var scene_path = scene_paths[current_scene_index]
		print("Loading scene: ", scene_path)
		if ResourceLoader.exists(scene_path):
			texture_to_load = load(scene_path)
			print("Scene loaded successfully")
		else:
			texture_to_load = fallback_texture
			print("Scene not found: ", scene_path, " - using fallback")
	else:
		# Load character-specific final scene
		var final_scene_path = _get_final_scene_path()
		print("Loading final scene: ", final_scene_path)
		if ResourceLoader.exists(final_scene_path):
			texture_to_load = load(final_scene_path)
			print("Final scene loaded successfully")
		else:
			texture_to_load = fallback_texture
			print("Final scene not found: ", final_scene_path, " - using fallback")
	
	scene_display.texture = texture_to_load
	
	# Make sure timer is stopped before starting
	if timer.is_stopped():
		timer.wait_time = 3.0
		timer.start()
		print("Timer started for 3 seconds")
	else:
		print("Timer already running!")

func _get_final_scene_path() -> String:
	# Get character names based on race results
	# race_results should contain [1st_place_character, 2nd_place_character, 3rd_place_character]
	if race_results.size() < 3:
		return "res://Asset/Animasi END/scene-default.png"
	
	var first = character_names[race_results[0]]
	var second = character_names[race_results[1]] 
	var third = character_names[race_results[2]]
	
	return "res://Asset/Animasi END/scene-" + first + "-" + second + "-" + third + ".png"

func _on_timer_timeout():
	print("Timer timeout! Current scene: ", current_scene_index)
	
	current_scene_index += 1
	
	if current_scene_index <= 4:  # Show 5 scenes total (0-4)
		_show_next_scene()
	else:
		# Winning scene finished
		print("All scenes finished")
		is_playing_scene = false
		hide()
		emit_signal("winning_scene_finished")

func _input(event):
	# Allow skipping scenes with any key press
	if visible and event.is_pressed():
		_skip_current_scene()

func _skip_current_scene():
	if !is_playing_scene:
		return
		
	print("Scene skipped by user input")
	timer.stop()
	_on_timer_timeout()
