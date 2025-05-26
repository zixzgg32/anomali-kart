extends Control

@export var speed_bar: TextureProgressBar
@export var max_speed: float = 120.0

var target_racer: Node

func _ready():
	if not speed_bar:
		speed_bar = get_node("SpeedBar")
	if not speed_bar:
		printerr("SpeedBar node not found!")
	if not target_racer:
		# Cari Player di seluruh scene
		target_racer = get_tree().get_root().find_child("Player", true, false)
	if not target_racer:
		printerr("Player node not found!")
	if speed_bar:
		speed_bar.min_value = 0
		speed_bar.max_value = max_speed

func _process(_delta):
	if target_racer and speed_bar:
		if target_racer.has_method("ReturnMovementSpeed"):
			var speed = target_racer.ReturnMovementSpeed()
			speed_bar.value = clamp(speed, 0, max_speed)
		else:
			printerr("Player node does not have ReturnMovementSpeed()")
