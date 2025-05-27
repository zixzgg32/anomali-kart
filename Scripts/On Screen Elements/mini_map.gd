extends Control

@export var map_sprite: NodePath = "Map"
@export var icon_sprite: NodePath = "Icon"
@export var player_path: NodePath = "/root/Main/Sprite Handler/Racers/Player"
@export var pseudo3d_path: NodePath = "/root/Main/Map"
@export var world_map_size: Vector2 = Vector2(1024, 1024) 
@export var minimap_size: Vector2 = Vector2(96, 96)       

var map_node: TextureRect
var icon_node: TextureRect
var player_node: Node
var pseudo3d_node: Node

func _ready():
	map_node = get_node(map_sprite)
	icon_node = get_node(icon_sprite)
	player_node = get_node_or_null(player_path)
	if not player_node:
		player_node = get_tree().get_root().find_child("Player", true, false)
	if not player_node:
		printerr("Player node not found for minimap!")
	pseudo3d_node = get_node_or_null(pseudo3d_path)
	if not pseudo3d_node:
		pseudo3d_node = get_tree().get_root().find_child("Map", true, false)
	if not pseudo3d_node:
		printerr("Map (Pseudo3D) node not found for minimap!")

func _process(_delta):
	if not player_node or not icon_node or not pseudo3d_node:
		return

	# Ambil posisi world player (Vector3)
	var player_map_pos: Vector3 = Vector3.ZERO
	if "_mapPosition" in player_node:
		player_map_pos = player_node._mapPosition

	# Ukuran world dan minimap
	var world_size = world_map_size
	var map_texture_size = Vector2(1024, 1024) # ukuran asli texture map
	var map_scale = map_node.scale
	var map_offset = map_node.position

	# Konversi posisi world ke posisi di texture map (0-1024)
	var map_x = player_map_pos.x / world_size.x * map_texture_size.x
	var map_y = player_map_pos.z / world_size.y * map_texture_size.y

	# Posisi icon di minimap (dalam pixel minimap, sebelum offset)
	var minimap_pos = Vector2(map_x, map_y) * map_scale

	# Koreksi agar icon berada di tengah titik
	var icon_size_scaled = icon_node.size * icon_node.scale
	var icon_center_offset = icon_size_scaled / 2

	# Set posisi icon (icon dan map sama-sama di-scale dan di-offset)
	icon_node.position = map_offset + minimap_pos - icon_center_offset
