extends Racer
signal lap_completed(lap_count)

var _default_rect := Rect2(10, 4, 53, 53) 
var _turn_left_rect := Rect2(295, 0, 65, 58) 
var _turn_right_rect := Rect2(228, 0, 65, 58) 
var _current_turn_rect := Rect2(10, 4, 53, 53)
var current_lap := 0
var is_on_lap_reader := false
var last_lap_position := Vector2i.ZERO
var lap_check_cooldown := 0.0
const LAP_COOLDOWN_TIME := 0.5 
var _base_speed := 1.0
# AI-specific variables
var _target_position := Vector3.ZERO
var _path := []
var _avoid_vector := Vector2.ZERO
var _avoid_timer := 0.0
var _decision_interval := 0.5
var _decision_timer := 0.0
var _aggressiveness := randf_range(0.7, 1.3)  # Random personality factor

func set_character_sprite(texture: Texture2D):
	if _spriteGFX and texture:
		_spriteGFX.texture = texture

func _ready():
	add_to_group("ai_racer")
	randomize()
	_decision_timer = randf_range(0, _decision_interval)  # Stagger decision making

func Setup(mapSize : int):
	SetMapSize(mapSize)
	_default_rect = Rect2(10, 4, 53, 53) 
	_turn_left_rect = Rect2(295, 0, 65, 58) 
	_turn_right_rect = Rect2(228, 0, 65, 58) 
	_current_turn_rect = _default_rect

func Update(mapForward : Vector3):
	# AI decision making
	_decision_timer -= get_process_delta_time()
	if _decision_timer <= 0:
		_make_ai_decision()
		_decision_timer = _decision_interval
	
	# Handle input based on AI decision
	var input = _calculate_ai_input()
	
	# Visual feedback for turning
	if input.x < 0: 
		_current_turn_rect = _turn_left_rect
	elif input.x > 0: 
		_current_turn_rect = _turn_right_rect
	else: 
		_current_turn_rect = _default_rect
	
	if _spriteGFX:
		_spriteGFX.region_rect = _current_turn_rect
		_spriteGFX.region_enabled = true
	
	if _isPushedBack:
		ApplyCollisionBump()
	
	var nextPos : Vector3 = _mapPosition + ReturnVelocity()
	var nextPixelPos : Vector2i = Vector2i(ceil(nextPos.x), ceil(nextPos.z))
	
	if _collisionHandler.IsCollidingWithWall(Vector2i(ceil(nextPos.x), ceil(_mapPosition.z))):
		nextPos.x = _mapPosition.x 
		SetCollisionBump(Vector3(-sign(ReturnVelocity().x), 0, 0))
		_avoid_vector = Vector2(sign(ReturnVelocity().x), 0) * -1
		_avoid_timer = 1.0
	
	if _collisionHandler.IsCollidingWithWall(Vector2i(ceil(_mapPosition.x), ceil(nextPos.z))):
		nextPos.z = _mapPosition.z
		SetCollisionBump(Vector3(0, 0, -sign(ReturnVelocity().z)))
		_avoid_vector = Vector2(0, sign(ReturnVelocity().z)) * -1
		_avoid_timer = 1.0
	
	HandleRoadType(nextPixelPos, _collisionHandler.ReturnCurrentRoadType(nextPixelPos))
	UpdateLapCount(nextPixelPos)
	SetMapPosition(nextPos)
	UpdateMovementSpeed()
	UpdateVelocity(mapForward)

func UpdateLapCount(current_position: Vector2i):
	var current_road_type = _collisionHandler.ReturnCurrentRoadType(current_position)
	
	if current_road_type == Globals.RoadType.LAP_READER:
		if lap_check_cooldown <= 0 and !is_on_lap_reader:
			var moved_forward = _has_moved_forward(current_position)
			
			if moved_forward:
				current_lap += 1
				emit_signal("lap_completed", current_lap)
				lap_check_cooldown = LAP_COOLDOWN_TIME
				
			is_on_lap_reader = true
	else:
		is_on_lap_reader = false
		lap_check_cooldown -= get_process_delta_time()
	
	last_lap_position = current_position

func _has_moved_forward(current_pos: Vector2i) -> bool:
	var movement_vector = current_pos - last_lap_position
	if movement_vector.length() < 2:  
		return false
	if abs(movement_vector.y) > abs(movement_vector.x):  
		return movement_vector.y > 0 
	else:  
		return movement_vector.x > 0  

# AI-specific functions
func _make_ai_decision():
	# Simple target selection - follow the track forward
	_target_position = _mapPosition + Vector3(0, 0, 20)  # Look ahead
	
	# If we're avoiding something, adjust target
	if _avoid_timer > 0:
		_target_position += Vector3(_avoid_vector.x, 0, _avoid_vector.y) * 10
		_avoid_timer -= _decision_interval

func _calculate_ai_input() -> Vector2:
	var input = Vector2.ZERO
	
	# Calculate direction to target
	var direction_to_target = Vector2(_target_position.x - _mapPosition.x, 
									_target_position.z - _mapPosition.z).normalized()
	
	# Add some randomness to make AI less perfect
	direction_to_target += Vector2(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1)) * (1.0 - _aggressiveness)
	direction_to_target = direction_to_target.normalized()
	
	# Convert to input values
	input.x = direction_to_target.x
	input.y = direction_to_target.y * _aggressiveness  # More aggressive AI will go faster
	
	# If we're close to target, slow down
	var distance_to_target = Vector2(_target_position.x - _mapPosition.x, 
								   _target_position.z - _mapPosition.z).length()
	if distance_to_target < 5:
		input.y *= 0.5
	
	# Apply avoidance vector if active
	if _avoid_timer > 0:
		input += _avoid_vector * 2.0
		input = input.normalized()
	
	_inputDir = input
	return input

func set_difficulty(difficulty: float):
	# difficulty should be between 0 (easy) and 1 (hard)
	_aggressiveness = lerp(0.5, 1.5, difficulty)
	_decision_interval = lerp(1.0, 0.3, difficulty)
	
#func set_rubber_band_speed(speed_factor: float):
	## Adjust movement speed based on rubber band effect
	#_base_movement_speed = _base_speed * speed_factor
