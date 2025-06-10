#Game.gd
extends Node2D
@export var _map : Node2D
@export var _collision : Node
@export var _player : Racer
@export var _spriteHandler : Node2D
@export var _animationHandler : Node
@export var _backgroundElements : Node2D
@export var bgm_player : AudioStreamPlayer 

var race_finish_screen: Control
var winning_scene_controller: Control
var race_finished := false
var race_results := []  # Will store finishing order [1st, 2nd, 3rd, 4th] as character indices

var _mapPosition: Vector3
var character_textures := [
	"res://Asset/Sprites/ballerina (2).png",
	"res://Asset/Sprites/Anomali cappucino assasion (1).png",
	"res://Asset/Sprites/anomali tralelelo tralala (3).png",
	"res://Asset/Sprites/anomali (2).png"
]

# Character mapping: 0=ballerina, 1=assasino, 2=tralalero, 3=tts
var character_index_to_name := {
	0: "ballerina",
	1: "assasino", 
	2: "tralalero",
	3: "tts"
}

var track_textures := [
	"res://Asset/New folder/Racetrack1.png",
	"res://Asset/New folder/Racetrack2.png",
	"res://Asset/New folder/Racetrack3.png",
	"res://Asset/New folder/Racetrack4.png"
]

var texture_tile := [
	"res://Textures/Texture/Sand.png",
	"res://Textures/Texture/Grass.png",
	"res://Textures/Texture/Mud.png",
	"res://Textures/Texture/Water.png"
]
var collision := [
	"res://Textures/Tracks/raceColl1.png",
	"res://Textures/Tracks/raceColl2.png",
	"res://Textures/Tracks/raceColl3.png",
	"res://Textures/Tracks/raceColl4.png"
]
var background := [
	"res://Asset/New folder/background_stage1 (1).png",
	"res://Asset/New folder/background_stage2 (2).png",
	"res://Asset/New folder/stage_background_cappucino.png",
	"res://Asset/New folder/bg4.png"
]

var sky := [
	"res://Asset/New folder/sky1.png",
	"res://Asset/New folder/sky2.png",
	"res://Asset/New folder/sky3.png",
	"res://Asset/New folder/sky4.png"
]

var bgmlist := [
	"res://Asset/sound/music/music/Desert Zone.mp3",
	"res://Asset/sound/music/music/jungle.mp3",
	"res://Asset/sound/music/music/the_spanish_ninja_c64_style.ogg",
	"res://Asset/sound/music/music/Retroracing Beach.mp3"
	
]
var icon := [
	"res://Asset/TPG-Asset-20250518T115225Z-1-001/TPG-Asset/128-frontview-ballerina.png",
	"res://Asset/TPG-Asset-20250518T115225Z-1-001/TPG-Asset/128-frontview-cappucinoassasino.png",
	"res://Asset/TPG-Asset-20250518T115225Z-1-001/TPG-Asset/128-frontview-tralalerotralala.png",
	"res://Asset/TPG-Asset-20250518T115225Z-1-001/TPG-Asset/128-frontview-tungtungsahur.png"
]

var PlayerLocation := [
	Vector3(378, 0, 434),
	Vector3(436.579, 0, 650.6988),
	Vector3(111.5937, 0, 294.0043),
	Vector3(484.6098, 0.0, 661.0996)
]
var mapStartRotationAngle := [
	Vector2(4.9, 9.4),
	Vector2(4.9, 4.8),
	Vector2(4.9, 3.15),
	Vector2(4.9, 4.7)
]
var ai_racers := []
@export var ai_scene : PackedScene
@export var ai_count := 3
@export var ai_start_positions := [
	[Vector3(360, 0, 400), Vector3(390, 0, 420), Vector3(370, 0, 440)],
	[Vector3(426, 0, 640), Vector3(446, 0, 660), Vector3(430, 0, 635)],
	[Vector3(100, 0, 290), Vector3(120, 0, 300), Vector3(110, 0, 280)],
	[Vector3(474, 0, 651), Vector3(490, 0, 670), Vector3(480, 0, 640)]
]


func _ready():
	add_to_group("game_manager")
	
	var winning_scene_scene = preload("res://Scenes/winning_scene_controller.tscn")
	winning_scene_controller = winning_scene_scene.instantiate()
	add_child(winning_scene_controller)
	winning_scene_controller.connect("winning_scene_finished", _on_winning_scene_finished)
	
	var finish_screen_scene = preload("res://Scenes/race_finish_screen.tscn")
	race_finish_screen = finish_screen_scene.instantiate()
	add_child(race_finish_screen)
	
	race_finish_screen.connect("rematch_requested", _on_rematch_requested)
	race_finish_screen.connect("menu_requested", _on_menu_requested)
	
	var selected_index = Globals.selected_character_index
	var texture_path = character_textures[selected_index]
	var texture = load(texture_path)
	var iconnn = icon[selected_index]
	var iconn = load(iconnn)
	var selected_index2 = Globals.selected_track_index
	var tracks = track_textures[selected_index2]
	var bg = background[selected_index2]
	var sk = sky[selected_index2]
	var bgm_path = bgmlist[selected_index2]
	var grass_texture = texture_tile[selected_index2]
	var collision_texture = collision[selected_index2]
	var tile = load(grass_texture)
	var track = load(tracks)
	var collision = load(collision_texture)
	var s = load(bg)
	var b = load(sk)
	var bgm_stream = load(bgm_path)
	var map = $Map
	var racer = $SpriteHandler/Racers/Player
	if selected_index2 >= 0 and selected_index2 < PlayerLocation.size():
		var new_pos_3d = PlayerLocation[selected_index2]
		var selected_pos = mapStartRotationAngle[selected_index2]
		racer._mapPosition = new_pos_3d
		racer.position = Vector2(new_pos_3d.x, new_pos_3d.z)
		if selected_index2 < mapStartRotationAngle.size():
				map._mapStartRotationAngle = mapStartRotationAngle[selected_index2]
		else:
				push_error("mapStartRotationAngle index out of bounds! Using default.")
				map._mapStartRotationAngle = Vector2.ZERO
		
	$mini_map/Map.texture = track
	$mini_map/Icon.texture = iconn
	$BackgroundElements/SkyLine.texture = s
	$BackgroundElements/Background.texture = b
	$Map.texture = track
	var material = $Map.material
	material.set_shader_parameter("trackTexture", track)
	material.set_shader_parameter("grassTexture", tile)
	
	var collision_node = $Map/CollisionHandler  
	collision_node._collisionMap = collision
	if collision_node.has_method("process_collision_data"):
		collision_node.process_collision_data()
	
	# Setup player first
	_player.set_character_sprite(texture)
	_map.Setup(Globals.screenSize, _player)
	_collision.Setup()
	_player.Setup(map.texture.get_size().x)
	_spriteHandler.Setup(_map.ReturnWorldMatrix(), _map.texture.get_size().x, _player)
	_animationHandler.Setup(_player)
	
	# Setup bot
	var bot = $SpriteHandler/Racers/Bot
	bot.Setup(map.texture.get_size().x)
	var bot_start_pos = ai_start_positions[selected_index2][0]
	bot._mapPosition = bot_start_pos
	bot.position = Vector2(bot_start_pos.x, bot_start_pos.z)
	bot.set_character_sprite(load(character_textures[1]))
	
	# Start countdown AFTER everything is setup
	var countdown = preload("res://Scenes/countdown.tscn").instantiate()
	add_child(countdown)
	
	# Start BGM
	bgm_player.stream = bgm_stream
	bgm_player.autoplay = true
	bgm_player.play()
	
	print("Game setup completed. Countdown should start now.")

# Function called by Player when race is finished
func _on_race_finished(player_position: int):
	if race_finished:
		return  # Prevent multiple calls
		
	race_finished = true
	print("Race finished! Player position: ", player_position)
	
	# Stop background music
	bgm_player.stop()
	
	# Generate race results for the winning scene
	_generate_race_results(player_position)
	
	# Show winning scene first
	winning_scene_controller.play_winning_scene(race_results)

func _generate_race_results(player_position: int):
	# Create a race results array with character indices
	# For now, we'll create a simple example - you can expand this with actual AI finishing logic
	race_results.clear()
	
	var player_character = Globals.selected_character_index
	var available_characters = [0, 1, 2, 3]  # All character indices
	available_characters.erase(player_character)  # Remove player character
	
	# Create results based on player position
	for i in range(4):
		if i == player_position - 1:  # Player's position (1st = index 0)
			race_results.append(player_character)
		else:
			# Add other characters in some order (you can make this more sophisticated)
			if available_characters.size() > 0:
				race_results.append(available_characters.pop_front())
	
	print("Race results generated: ", race_results)
	for i in range(race_results.size()):
		print("Position ", i+1, ": ", character_index_to_name[race_results[i]])

func _on_winning_scene_finished():
	# Show the race finish screen after winning scene
	var player_position = race_results.find(Globals.selected_character_index) + 1
	race_finish_screen.show_race_result(player_position)

func _on_rematch_requested():
	print("Rematch requested")
	# Restart the current scene
	get_tree().reload_current_scene()

func _on_menu_requested():
	print("Back to menu requested")
	# Change to main menu scene - adjust path as needed
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
	
func _process(_delta):
	_map.Update(_player)
	_player.Update(_map.ReturnForward())
	_spriteHandler.Update(_map.ReturnWorldMatrix())
	_animationHandler.Update()
	_backgroundElements.Update(_map.ReturnMapRotation())
	
	var bot = $SpriteHandler/Racers/Bot
	if is_instance_valid(bot):
		bot.Update(_map.ReturnForward())
