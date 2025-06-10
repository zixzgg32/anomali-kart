extends CharacterBody3D

@export var collision_handler_path: NodePath
@export var speed: float = 8.0
@export var gravity: float = 20.0


var racing_line: Array = []
var checkpoints: Array = []
var checkpoint_passed: Array = []
var current_target: int = 0
var current_lap: int = 0

var collision_handler
var speed_multiplier := 1.0
var last_checkpoint_pos: Vector3 = Vector3.ZERO

func _ready():
	global_transform.origin = Vector3(-11, 5, -10)
	collision_handler = get_node(collision_handler_path)
	_generate_racing_line_and_checkpoints()
	checkpoint_passed.resize(checkpoints.size())
	checkpoint_passed.fill(false)

func _physics_process(delta):
	if racing_line.size() == 0:
		return

	# Gravitasi
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	var target = racing_line[current_target]["position"]
	var to_target = (target - global_transform.origin)
	var direction = to_target.normalized()

	# Steering: Hadapkan bot ke target secara bertahap
	var forward = -global_transform.basis.z.normalized()
	var steer_angle = forward.signed_angle_to(direction, Vector3.UP)
	var max_steer = 1.5 * delta
	steer_angle = clamp(steer_angle, -max_steer, max_steer)
	rotate_y(steer_angle)

	forward = -global_transform.basis.z.normalized()

	# Deteksi tipe jalan di posisi bot
	var road_type = collision_handler.GetRoadTypeFromWorld(global_transform.origin)
	handle_road_type(road_type)

	# Simpan posisi checkpoint terakhir yang dilewati
	for i in range(checkpoints.size()):
		if checkpoint_passed[i]:
			last_checkpoint_pos = checkpoints[i]

	# Jika bot terlalu jauh dari racing_line, cari racing_line terdekat
	if global_transform.origin.distance_to(target) > 10.0:
		var nearest_idx = 0
		var min_dist = global_transform.origin.distance_to(racing_line[0]["position"])
		for i in range(1, racing_line.size()):
			var d = global_transform.origin.distance_to(racing_line[i]["position"])
			if d < min_dist:
				min_dist = d
				nearest_idx = i
		current_target = nearest_idx
		target = racing_line[current_target]["position"]
		direction = (target - global_transform.origin).normalized()

	# Jika bot kena wall, putar arah acak agar tidak stuck
	if road_type == 5:
		rotate_y(randf_range(-0.5, 0.5))
		velocity = Vector3.ZERO
		return

	velocity = forward * speed * speed_multiplier
	move_and_slide()

	# Ganti target jika sudah dekat
	if global_transform.origin.distance_to(target) < 2.0:
		current_target = (current_target + 1) % racing_line.size()
	_check_checkpoint()

func handle_road_type(road_type: int):
	match road_type:
		0, 1, 2, 3, 4: # Checkpoint1-5
			speed_multiplier = 1.0
		5: # Wall
			speed_multiplier = 0.0
		6: # Rumput
			speed_multiplier = 0.7
		7: # Air
			speed_multiplier = 0.2
		8: # Finish
			speed_multiplier = 1.0
		9: # Jalan
			speed_multiplier = 1.0
		_:
			speed_multiplier = 1.0

func _generate_racing_line_and_checkpoints():
	var img = collision_handler._collisionMap.get_image()
	var width = img.get_width()
	var height = img.get_height()
	var tolerance = 0.1
	var points = []
	var found_checkpoints = []
	var road_type_colors = collision_handler._roadTypeColors

	for x in range(0, width, 16):
		for y in range(0, height, 16):
			var c = img.get_pixel(x, y)
			var matched_index := -1
			for i in range(road_type_colors.size()):
				var color = road_type_colors[i]
				if abs(c.r - color.r) < tolerance and abs(c.g - color.g) < tolerance and abs(c.b - color.b) < tolerance:
					matched_index = i
					break
			if matched_index != -1:
				var world_x = (float(x)/width - 0.5) * collision_handler.world_size.x
				var world_z = (float(y)/height - 0.5) * collision_handler.world_size.y
				points.append({ 
					"position": Vector3(world_x, 0, world_z), 
					"road_type": matched_index 
				})
				if matched_index >= 0 and matched_index <= 4:
					found_checkpoints.append(Vector3(world_x, 0, world_z))

	# Urutkan points jadi racing line (nearest neighbor, simple)
	var ordered = []
	if points.size() > 0:
		ordered.append(points[0])
		points.remove_at(0)
		while points.size() > 0:
			var last = ordered[-1]["position"]
			var nearest = 0
			var min_dist = last.distance_to(points[0]["position"])
			for i in range(1, points.size()):
				var d = last.distance_to(points[i]["position"])
				if d < min_dist:
					min_dist = d
					nearest = i
			ordered.append(points[nearest])
			points.remove_at(nearest)
	ordered.reverse()
	racing_line = ordered
	checkpoints = found_checkpoints

func _check_checkpoint():
	if checkpoints.size() == 0:
		return
	for i in range(checkpoints.size()):
		if not checkpoint_passed[i] and global_transform.origin.distance_to(checkpoints[i]) < 4.0:
			checkpoint_passed[i] = true
			print("Checkpoint ", i+1, " passed!")
	if checkpoint_passed.all(func(x): return x):
		current_lap += 1
		print("BOT selesai lap ke-", current_lap)
		checkpoint_passed.fill(false)
