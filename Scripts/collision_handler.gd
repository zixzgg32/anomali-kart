extends Node

@export var _collisionMap : Texture
var _textureImage : Image 
var _textureWidth : int = 1024
var _textureHeight : int = 1024

@export var _roadTypeColors : Array[Color]
@export var world_size := Vector2(100, 100) # Sesuaikan ukuran world-mu secara XZ

func _ready():
	Setup()

func Setup():
	if _collisionMap:
		_textureImage = _collisionMap.get_image()
		_textureWidth = _textureImage.get_width()
		_textureHeight = _textureImage.get_height()
	else:
		push_error("CollisionHandler: _collisionMap belum di-assign!")

func AreColorsEqual(a : Color, b : Color, tolerance : float = 0.05):
	return abs(a.r - b.r) <= tolerance and abs(a.g - b.g) <= tolerance and abs(a.b - b.b) <= tolerance

func ReturnCurrentRoadType(position : Vector2i) -> int:
	if position.x < 0 or position.y < 0 or position.x >= _textureWidth or position.y >= _textureHeight:
		return -1
	var pixelColor : Color = _textureImage.get_pixel(position.x, position.y)
	for i in range(_roadTypeColors.size()):
		if AreColorsEqual(pixelColor, _roadTypeColors[i]):
			return i
	return -1 # Tidak ditemukan



func GetRoadTypeFromWorld(world_pos: Vector3) -> int:
	var image_pos = WorldToImage(world_pos)
	return ReturnCurrentRoadType(image_pos)

func WorldToImage(world_pos: Vector3) -> Vector2i:
	var x = int(clamp((world_pos.x / world_size.x + 0.5) * _textureWidth, 0, _textureWidth - 1))
	var y = int(clamp((world_pos.z / world_size.y + 0.5) * _textureHeight, 0, _textureHeight - 1))
	return Vector2i(x, y)
