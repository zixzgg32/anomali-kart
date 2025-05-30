extends Node2D

@export var lap_sprites: Array[Sprite2D] = []

func _ready():
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var player = players[0]
		if player.has_signal("lap_completed"):
			player.connect("lap_completed", _on_lap_completed)
		else:
			push_error("Player missing lap_completed signal!")
	else:
		push_error("No player found in group!")
	
	update_lap_display(0)
func _on_lap_completed(lap_count):
	print("Lap updated: ", lap_count)
	update_lap_display(lap_count)
func update_lap_display(lap_count):
	for i in range(lap_sprites.size()):
		if lap_sprites[i] and is_instance_valid(lap_sprites[i]):
			lap_sprites[i].visible = (i == lap_count - 1)
