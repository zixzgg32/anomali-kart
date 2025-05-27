extends Racer
var _input_dir: Vector2 = Vector2.ZERO  
var velocity: Vector2 = Vector2.ZERO
var current_checkpoint: int = 0      
var target_position: Vector2 = Vector2.ZERO
var checkpoints: Array[Vector2] = [
	Vector2(100, 200), 
	Vector2(300, 150),
	Vector2(500, 400)
]


@export var reaction_distance: float = 50.0
@export var steering_force: float = 0.5

func _ready():
	target_position = checkpoints[0]

func _process(_delta):
	_input_dir = calculate_ai_input()
	UpdateMovementSpeed()

func calculate_ai_input() -> Vector2:
	var input = Vector2.ZERO
	
	# 1. Arahkan ke checkpoint
	var direction = (target_position - position).normalized()
	input.y = 1  # Selalu maju
	
	# 2. Belok berdasarkan arah checkpoint
	var angle_to_target = direction.angle()
	var current_angle = velocity.angle() if velocity.length() > 0 else 0
	var angle_diff = angle_to_target - current_angle
	
	# Belok kiri/kanan berdasarkan sudut
	if angle_diff > 0.1:
		input.x = 1  # Belok kanan
	elif angle_diff < -0.1:
		input.x = -1  # Belok kiri
	
	if detect_obstacle():
		input.x = -sign(get_obstacle_direction()) * steering_force
	
	return input

func detect_obstacle() -> bool:
	# Gunakan RayCast2D untuk deteksi
	var raycast = $RayCast2D
	raycast.target_position = Vector2(reaction_distance, 0)
	raycast.force_raycast_update()
	return raycast.is_colliding()

func get_obstacle_direction() -> float:
	# Kembalikan 1 jika rintangan di kanan, -1 jika di kiri
	return 1.0  # Implementasi deteksi arah sesungguhnya

func _on_checkpoint_reached(body):
	if body == self:
		current_checkpoint = (current_checkpoint + 1) % checkpoints.size()
		target_position = checkpoints[current_checkpoint]
