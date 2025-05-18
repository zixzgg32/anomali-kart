extends Control

@export var track_names: Array[String] = ["Track 1", "Track 2", "Track 3", "Track 4"]
@export var track_sprites: Array[NodePath] = [
	"Track1",
	"Track2",
	"Track3",
	"Track4"
]
var current_index: int = 0

func _ready():
	for i in range(track_sprites.size()):
		var sprite = get_node_or_null(track_sprites[i])
		if sprite == null:
			print("Error: Node not found for path:", track_sprites[i])
	$Label.text = track_names[current_index]
	update_selection()

func _input(event):
	if event.is_action_pressed("ui_left"):
		current_index = (current_index - 1 + track_sprites.size()) % track_sprites.size()
		update_selection()
	elif event.is_action_pressed("ui_right"):
		current_index = (current_index + 1) % track_sprites.size()
		update_selection()
	elif event.is_action_pressed("ui_accept"):
		confirm_selection() 

func update_selection():
	for i in range(track_sprites.size()):
		var sprite = get_node_or_null(track_sprites[i])
		if sprite:
			sprite.visible = (i == current_index)
			if i == current_index:
				var center = get_viewport_rect().size / 2
				sprite.position = center - sprite.size / 2
				print("Selected:", track_names[i], "Pos:", sprite.position)
			else:
				print("Hidden:", track_names[i])
	$Label.text = track_names[current_index]

func confirm_selection():
	Globals.selected_track_index = current_index
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
