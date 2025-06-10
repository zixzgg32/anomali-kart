extends RigidBody3D

@export var spawn_position: Vector3 = Vector3.ZERO
@export var spawn_rotation: Vector3 = Vector3.ZERO

@export var gravity: float = 20.0
@export var acceleration: float = 20.0
@export var deacceleration: float = 30.0
var current_speed := 0.0

var move_speed = 10.0
var rotate_speed = 2.0
var speed_multiplier := 1.0

var current_checkpoint := 0
var total_checkpoints := 5
var checkpoint_passed := []
var current_lap := 0
var is_on_finish := false

const MAP_SIZE : float = 100.0
const IMG_SIZE : float = 1024.0

@onready var collision_handler = get_node("/root/World3D/CollisionHandler")

func _ready():
	global_transform.origin = spawn_position
	rotation_degrees = spawn_rotation
	checkpoint_passed.resize(total_checkpoints)
	checkpoint_passed.fill(false)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	var forward_dir = -transform.basis.z
	var next_pos = global_position + forward_dir * 2.0
	var road_type = collision_handler.GetRoadTypeFromWorld(next_pos)

	match road_type:
		9: # Jalan
			speed_multiplier = 1.0
		5: # Tembok
			speed_multiplier = 0.0
			rotate_y(randf_range(-1.0, 1.0) * rotate_speed * delta) # Hindari stuck
		6: # Rumput
			speed_multiplier = 0.7
		7: # Air
			speed_multiplier = 0.3
		_:
			speed_multiplier = 1.0

	# Bergerak
	current_speed = lerp(current_speed, move_speed * speed_multiplier, acceleration * delta)
	var direction = forward_dir * current_speed
	velocity.x = direction.x
	velocity.z = direction.z

	# Putar menuju checkpoint saat ini
	seek_checkpoint(delta)

	move_and_slide()

	# Update lap
	var now_road_type = collision_handler.GetRoadTypeFromWorld(global_position)
	update_lap_check(now_road_type)

func seek_checkpoint(delta):
	# Contoh koordinat world untuk checkpoint (kamu bisa ubah sesuai posisi aslinya)
	var checkpoint_positions = [
		Vector3(-40, 0, 30),
		Vector3(-20, 0, -20),
		Vector3(0, 0, 20),
		Vector3(20, 0, -25),
		Vector3(40, 0, 10)
	]

	if current_checkpoint >= checkpoint_positions.size():
		return

	var target = checkpoint_positions[current_checkpoint]
	var direction = (target - global_position).normalized()
	var forward = -transform.basis.z

	var angle = forward.signed_angle_to(direction, Vector3.UP)
	rotate_y(angle * rotate_speed * delta)

func update_lap_check(road_type: int):
	if road_type == current_checkpoint:
		checkpoint_passed[road_type] = true
		print("Checkpoint ", road_type + 1, " passed!")
		current_checkpoint += 1

	if road_type == 8 and checkpoint_passed.all(func(x): return x) and not is_on_finish:
		current_lap += 1
		print("BOT selesai lap ke-", current_lap)
		checkpoint_passed.fill(false)
		current_checkpoint = 0
		is_on_finish = true
	elif road_type != 8:
		is_on_finish = false
