extends Node2D
@export var needle: Sprite2D  
@export var max_speed: float = 120.0  
@export var min_angle: float = -150.0  
@export var max_angle: float = 150.0   

var target_racer: Racer  

func _ready():
	if not needle:
		needle = get_node("Needle")  
	if not target_racer:
		target_racer = get_parent().find_child("Player") 

func _process(delta):
	if target_racer and needle:
		
		var speed = target_racer.ReturnMovementSpeed()
		
		var angle = map_value(speed, 0, max_speed, min_angle, max_angle)
		
		needle.rotation_degrees = angle


func map_value(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
	return (value - from_min) * (to_max - to_min) / (from_max - from_min) + to_min
