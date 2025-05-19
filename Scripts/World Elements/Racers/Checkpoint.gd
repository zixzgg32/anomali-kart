extends Area2D
func _on_body_entered(body: Node2D):
	if body.is_in_group("bot"):
		body._on_checkpoint_reached()
