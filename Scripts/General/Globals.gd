#Globals.gd
extends Node

var screenSize : Vector2 = Vector2(640, 360)
var selected_character_index : int
var selected_track_index : int
var player1_selection: int = -1
var player2_selection: int = -1
enum RoadType {
	VOID = 0,
	ROAD = 1,
	GRAVEL = 2,
	OFF_ROAD = 3,
	WALL = 4,
	SINK = 5,
	LAP_READER = 6 #finish/start line
} 
