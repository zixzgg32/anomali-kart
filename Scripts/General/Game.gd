#Game.gd
extends Node2D
@export var _map : Node2D
@export var _collision : Node
@export var _player : Racer
@export var _spriteHandler : Node2D
@export var _animationHandler : Node
@export var _backgroundElements : Node2D
@export var bgm_player : AudioStreamPlayer 

var character_textures := [
	"res://Asset/Sprites/a5.png",
	"res://Asset/Sprites/Anomali cappucino assasion.png",
	"res://Asset/Sprites/anomali tralelelo tralala (1).png",
	"res://Asset/Sprites/tung tung tung sahur.png"
]

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
	"res://Textures/Tracks/Racetrack1Collision.png",
	"res://Textures/Tracks/Racetrack2Collision.png",
	"res://Textures/Tracks/Racetrack3Collision.png",
	"res://Textures/Tracks/Racetrack4Collision.png"
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

func _ready():
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
	var countdown = preload("res://Scenes/countdown.tscn").instantiate()
	add_child(countdown)
	
	_player.set_character_sprite(texture)
	_map.Setup(Globals.screenSize, _player)
	_collision.Setup()
	_player.Setup(_map.texture.get_size().x)
	_spriteHandler.Setup(_map.ReturnWorldMatrix(), _map.texture.get_size().x, _player)
	_animationHandler.Setup(_player)
	bgm_player.stream = bgm_stream
	bgm_player.autoplay = true
	bgm_player.play()
	

func _process(_delta):
	_map.Update(_player)
	_player.Update(_map.ReturnForward())
	_spriteHandler.Update(_map.ReturnWorldMatrix())
	_animationHandler.Update()
	_backgroundElements.Update(_map.ReturnMapRotation())
