#Game.gd
extends Node2D
@export var _map : Node2D
@export var _collision : Node
@export var _player : Racer
@export var _spriteHandler : Node2D
@export var _animationHandler : Node
@export var _backgroundElements : Node2D

var character_textures := [
	"res://Asset/Sprites/anomali garammadu.png",
	"res://Asset/Sprites/Anomali cappucino assasion.png",
	"res://Asset/Sprites/anomali tralelelo tralala (1).png",
	"res://Asset/Sprites/tung tung tung sahur.png"
]


func _ready():
	var selected_index = Globals.selected_character_index
	var texture_path = character_textures[selected_index]
	var texture = load(texture_path)
	_player.set_character_sprite(texture)
	_map.Setup(Globals.screenSize, _player)
	_collision.Setup()
	_player.Setup(_map.texture.get_size().x)
	_spriteHandler.Setup(_map.ReturnWorldMatrix(), _map.texture.get_size().x, _player)
	_animationHandler.Setup(_player)

func _process(_delta):
	_map.Update(_player)
	_player.Update(_map.ReturnForward())
	_spriteHandler.Update(_map.ReturnWorldMatrix())
	_animationHandler.Update()
	_backgroundElements.Update(_map.ReturnMapRotation())
