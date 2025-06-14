extends SpringArm3D

@export var target : Node3D
@export var follow_speed = 5.0
@export var rotation_offset = Vector3(-30, 0, 0)

func _ready():
	set_as_top_level(true)
	if not target:
		target = get_tree().get_root().get_node("multiplayer/Player1") # Pastikan path sesuai
	# Sinkronkan rotasi awal kamera dengan rotasi player
	if target:
		rotation.y = target.rotation.y
		rotation.x = deg_to_rad(rotation_offset.x)

func _process(delta):
	if target:
		# Ikuti posisi player
		global_transform.origin = target.global_transform.origin
		# Ikuti rotasi player
		rotation.y = lerp_angle(rotation.y, target.rotation.y, follow_speed * delta)
		# Tambahkan offset rotasi (opsional)
		rotation.x = lerp_angle(rotation.x, deg_to_rad(rotation_offset.x), follow_speed * delta)
