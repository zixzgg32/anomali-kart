extends Control

@export var character_names: Array[String] = ["Character 1", "Character 2", "Character 3"]
@export var character_sprites: Array[NodePath] = [
	"HBoxContainer/Character1",
	"HBoxContainer/Character2",
	"HBoxContainer/Character3"
]
var current_index: int = 0

func _ready():
	for path in character_sprites:
		var node = get_node_or_null(path)
		if node == null:
			print("Error: Node not found for path:", path)
	update_selection()

func _input(event):
	if event.is_action_pressed("ui_left"):
		current_index = max(0, current_index - 1)
		update_selection()
	elif event.is_action_pressed("ui_right"):
		current_index = min(character_sprites.size() - 1, current_index + 1)
		update_selection()
	elif event.is_action_pressed("ui_accept"):
		confirm_selection()

func update_selection():
	for i in range(character_sprites.size()):
		var sprite = get_node_or_null(character_sprites[i])
		if sprite:
			sprite.position = Vector2(0, 0)  # Reset posisi
			sprite.scale = Vector2(1, 1)    # Reset skala
		else:
			print("Error: Node not found for path:", character_sprites[i])

	var selected_sprite = get_node_or_null(character_sprites[current_index])
	if selected_sprite:
		selected_sprite.position = Vector2(0, -20)  # Geser ke atas sedikit
		selected_sprite.scale = Vector2(1.2, 1.2)  # Perbesar sedikit
		$Label.text = character_names[current_index]
	else:
		print("Error: Selected node not found for index:", current_index)
func confirm_selection():
	print("Selected character:", character_names[current_index])
	# Pindah ke scene berikutnya
	get_tree().change_scene("res://Scene/trackSelection.tscn")
