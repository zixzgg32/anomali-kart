extends Control

@export var speed_bar: TextureProgressBar
@export var max_speed: float = 120.0
@export var name_label: Label

# Array nama karakter, urutannya harus sama dengan characterSelection
var character_names := [" Balerina Capucina", "Cappucino Assasino", "Tralalero Tralala", "Tung Tung Tung Sahur"]

var target_racer: Node

func _ready():
	if not speed_bar:
		speed_bar = get_node("SpeedBar")
	if not speed_bar:
		printerr("SpeedBar node not found!")
	if not name_label:
		name_label = get_node_or_null("NameLabel")
	if not target_racer:
		target_racer = get_tree().get_root().find_child("Player", true, false)
	if not target_racer:
		printerr("Player node not found!")
	if speed_bar:
		speed_bar.min_value = 0
		speed_bar.max_value = max_speed

	# Set nama karakter di label dari index yang dipilih
	if name_label:
		var idx = Globals.selected_character_index
		if idx >= 0 and idx < character_names.size():
			name_label.text = character_names[idx]
		else:
			name_label.text = "Player"

func _process(_delta):
	if target_racer and speed_bar:
		if target_racer.has_method("ReturnMovementSpeed"):
			var speed = target_racer.ReturnMovementSpeed()
			speed_bar.value = clamp(speed, 0, max_speed)
		else:
			printerr("Player node does not have ReturnMovementSpeed()")
