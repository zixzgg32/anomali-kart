extends Camera3D

@export var target : NodePath
@export var offset = Vector3(0, 1, 4)

func _ready():
	if target.is_empty():
		push_error("Target not assigned!")
	set_physics_process(true)

func _physics_process(delta):
	var player = get_node(target)
	if player:
		var basis = player.global_transform.basis
		var rotated_offset = basis * offset
		global_transform.origin = player.global_transform.origin + rotated_offset
		global_transform.basis = player.global_transform.basis
