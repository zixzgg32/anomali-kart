extends Control

@export var character_names: Array[String] = ["Character 1", "Character 2", "Character 3", "Character 4"]
@export var character_sprites: Array[NodePath] = [
	"Character1",
	"Character2",
	"Character3",
	"Character4"
]
var current_index: int = 0

func _ready():
	for i in range(character_sprites.size()):
		var sprite = get_node_or_null(character_sprites[i])
		if sprite == null:
			print("Error: Node not found for path:", character_sprites[i])
	$Label.text = character_names[current_index]
	update_selection()

func _input(event):
	if event.is_action_pressed("ui_left"):
		current_index = (current_index - 1 + character_sprites.size()) % character_sprites.size()
		update_selection()
	elif event.is_action_pressed("ui_right"):
		current_index = (current_index + 1) % character_sprites.size()
		update_selection()
	elif event.is_action_pressed("ui_accept"):
		confirm_selection() 

func update_selection():
	for i in range(character_sprites.size()):
		var sprite = get_node_or_null(character_sprites[i])
		if sprite:
			sprite.visible = (i == current_index)
			if i == current_index:
				var center = get_viewport_rect().size / 2
				sprite.position = center - sprite.size / 2
				print("Selected:", character_names[i], "Pos:", sprite.position)
			else:
				print("Hidden:", character_names[i])
	$Label.text = character_names[current_index]
	
func confirm_selection():
	Globals.selected_character_index = current_index
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
