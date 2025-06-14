extends Control

@export var speed_bar: TextureProgressBar
@export var speed_bar1: TextureProgressBar
@export var max_speed: float = 10.0
@export var name_label: Label

# Array nama karakter, urutannya harus sama dengan characterSelection
var character_names := [" Balerina Capucina", "Cappucino Assasino", "Tralalero Tralala", "Tung Tung Tung Sahur"]

var target_racer: Node
var target_racer1
func _ready():
	if not speed_bar:
		speed_bar = get_node("SpeedBar")
		speed_bar1 = get_node("SpeedBar2")
	if not speed_bar:
		printerr("SpeedBar node not found!")
	if not name_label:
		name_label = get_node_or_null("NameLabel")
	if not target_racer:
		target_racer = get_tree().get_root().find_child("Player1", true, false)
		target_racer1 = get_tree().get_root().find_child("Player2", true, false)
	if not target_racer:
		printerr("Player node not found!")
	if speed_bar:
		speed_bar.min_value = 0
		speed_bar.max_value = max_speed
		speed_bar1.min_value = 0
		speed_bar1.max_value = max_speed
	# Set nama karakter di label dari index yang dipilih
	if name_label:
		var idx = Globals.selected_character_index
		if idx >= 0 and idx < character_names.size():
			name_label.text = character_names[idx]
		else:
			name_label.text = "Player"

func _process(_delta):
	if target_racer and speed_bar:
		var speed = target_racer.velocity.length() 
		speed_bar.value = clamp(speed, 0, max_speed)
		speed_bar1.value =  clamp(speed, 0, max_speed)
