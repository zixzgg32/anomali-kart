extends CharacterBody3D

@export var spawn_position: Vector3 = Vector3.ZERO
@export var spawn_rotation: Vector3 = Vector3.ZERO
@export var gravity: float = 20.0

@export var acceleration: float = 20.0
@export var deacceleration: float = 30.0
var current_speed := 0.0

var move_speed = 10.0
var rotate_speed = 2.0
var speed_multiplier := 1.0

var has_passed_checkpoint := false
var current_lap := 0
var is_on_finish := false

var particle_texture = load("res://Textures/Racers/Particles/Racer_Particles.png")


@onready var collision_handler = get_node("/root/multiplayer/CollisionHandler")
@onready var car_sprite = $CarSprite
var default_sprite_texture : Texture = null

const MAP_SIZE : float = 100.0
const IMG_SIZE : float = 1024.0
var total_checkpoints := 5
var checkpoint_passed := []

func _ready():
	global_transform.origin = spawn_position
	rotation_degrees = spawn_rotation

	# Player hanya di layer 1, hanya mendeteksi wall (misal layer 3)
	collision_layer = 1
	collision_mask = 4

	checkpoint_passed = []
	for i in range(total_checkpoints):
		checkpoint_passed.append(false)
	if car_sprite:
		default_sprite_texture = car_sprite.texture

func _physics_process(delta):
	# Gravitasi
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	var move_input = Input.get_axis("p2_accelerate", "p2_brake")
	var rotate_input = Input.get_axis("p2_right", "p2_left")
	rotate_y(rotate_input * rotate_speed * delta)

	# Smooth acceleration/deacceleration
	if move_input != 0:
		current_speed = lerp(current_speed, float(move_input) * move_speed * speed_multiplier, acceleration * delta)
	else:
		current_speed = lerp(current_speed, 0.0, deacceleration * delta)

	# Hitung velocity awal
	var direction = transform.basis.z * current_speed
	velocity.x = direction.x
	velocity.z = direction.z

	# Cek wall di sumbu X
	var next_pos_x = global_transform.origin + Vector3(velocity.x, 0, 0) * delta
	var px_x = int((next_pos_x.x / MAP_SIZE + 0.5) * IMG_SIZE)
	var pz_x = int((next_pos_x.z / MAP_SIZE + 0.5) * IMG_SIZE)
	var road_type_x = collision_handler.ReturnCurrentRoadType(Vector2i(px_x, pz_x))
	if road_type_x == 5:
		velocity.x = 0

	# Cek wall di sumbu Z
	var next_pos_z = global_transform.origin + Vector3(0, 0, velocity.z) * delta
	var px_z = int((next_pos_z.x / MAP_SIZE + 0.5) * IMG_SIZE)
	var pz_z = int((next_pos_z.z / MAP_SIZE + 0.5) * IMG_SIZE)
	var road_type_z = collision_handler.ReturnCurrentRoadType(Vector2i(px_z, pz_z))
	if road_type_z == 5:
		velocity.z = 0

	# Efek permukaan & lap
	var world_pos = global_transform.origin
	var px_now = int((world_pos.x / MAP_SIZE + 0.5) * IMG_SIZE)
	var pz_now = int((world_pos.z / MAP_SIZE + 0.5) * IMG_SIZE)
	var pixel_pos_now = Vector2i(px_now, pz_now)
	var road_type = collision_handler.ReturnCurrentRoadType(pixel_pos_now)
	handle_road_type(road_type)
	update_lap_count(road_type)

	move_and_slide()
	


func handle_road_type(road_type: int):
	match road_type:
		0, 1, 2, 3, 4: # Checkpoint1-5
			speed_multiplier = 1.0
			restore_sprite()
		5: # Wall
			speed_multiplier = 0.0
			restore_sprite()
		6: # Rumput
			speed_multiplier = 0.7
			restore_sprite()
		7: # Air
			speed_multiplier = 0.2
			set_sprite_sink()
		8: # Finish
			speed_multiplier = 1.0
			restore_sprite()
		9: # Jalan
			speed_multiplier = 1.0
			restore_sprite()
		_:
			speed_multiplier = 1.0
			restore_sprite()

func set_sprite_sink():
	if car_sprite:
		car_sprite.texture = preload("res://Textures/Racers/Particles/Racer_Particles.png")

func restore_sprite():
	if car_sprite and default_sprite_texture and car_sprite.texture != default_sprite_texture:
		car_sprite.texture = default_sprite_texture

func update_lap_count(road_type: int):
	# Anggap index 0-4 adalah checkpoint1-5, index 8 adalah finish
	if road_type in [0,1,2,3,4]:
		checkpoint_passed[road_type] = true
	if road_type == 8: # Finish
		if checkpoint_passed.all(func(x): return x) and not is_on_finish:
			current_lap += 1
			print("Lap completed! Current lap: ", current_lap)
			for i in range(total_checkpoints):
				checkpoint_passed[i] = false
			is_on_finish = true
			if current_lap >= 4:
				print("MENANG! Game akan ditutup.")
				get_tree().quit()
	else:
		is_on_finish = false
