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

# AI-specific variables
var _aggressiveness := randf_range(0.7, 1.3)
var _decision_interval := 0.3
var _decision_timer := 0.0
var _avoid_vector := Vector2.ZERO
var _avoid_timer := 0.0

# Racing AI variables
var _race_line_points := []
var _current_target_index := 0
var _look_ahead_distance := 50.0
var _steering_sensitivity := 2.0
var can_move := false

func set_character_sprite(texture: Texture2D):
	if _spriteGFX and texture:
		_spriteGFX.texture = texture
		_spriteGFX.region_enabled = false

func _ready():
	add_to_group("ai_racer")
	add_to_group("bot")
	randomize()
	_decision_timer = randf_range(0, _decision_interval)
	_aggressiveness = randf_range(0.8, 1.2)
	
	# Connect to countdown
	call_deferred("_connect_to_countdown")
	
	# Initialize racing line
	_generate_race_line()
	
	if not _spriteGFX or not is_instance_valid(_spriteGFX):
		_spriteGFX = get_node_or_null("GFX")

func _connect_to_countdown():
	await get_tree().process_frame
	await get_tree().process_frame
	
	var countdown_nodes = get_tree().get_nodes_in_group("countdown")
	if countdown_nodes.size() > 0:
		var countdown = countdown_nodes[0]
		if countdown.has_signal("countdown_finished"):
			if not countdown.is_connected("countdown_finished", _on_countdown_finished):
				countdown.connect("countdown_finished", _on_countdown_finished)
				print("Bot connected to countdown signal")
	else:
		# Allow movement immediately if no countdown
		can_move = true

func _on_countdown_finished():
	can_move = true
	print("Bot can now move after countdown!")

func _generate_race_line():
	# Generate a basic racing line - you can make this more sophisticated
	# For now, create a simple circular path
	var center = Vector2(512, 512)  # Assuming 1024x1024 map
	var radius = 300
	var points = 32  # Number of waypoints
	
	_race_line_points.clear()
	for i in range(points):
		var angle = (float(i) / points) * TAU
		var point = center + Vector2(cos(angle), sin(angle)) * radius
		_race_line_points.append(Vector3(point.x, 0, point.y))

func Setup(mapSize: int):
	SetMapSize(mapSize)
	_default_rect = Rect2(10, 4, 53, 53) 
	_turn_left_rect = Rect2(295, 0, 65, 58) 
	_turn_right_rect = Rect2(228, 0, 65, 58) 
	_current_turn_rect = _default_rect
	
	# Assign collision handler
	if get_tree().get_root().has_node("Main/Map/CollisionHandler"):
		_collisionHandler = get_tree().get_root().get_node("Main/Map/CollisionHandler")

func Update(mapForward: Vector3):
	if not can_move:
		_inputDir = Vector2.ZERO
		return
	
	# AI decision making
	_decision_timer -= get_process_delta_time()
	if _decision_timer <= 0:
		_make_ai_decision()
		_decision_timer = _decision_interval
	
	# Calculate AI input
	var input = _calculate_ai_input()
	_inputDir = input
	
	# Visual feedback for turning
	if input.x < -0.1: 
		_current_turn_rect = _turn_left_rect
	elif input.x > 0.1: 
		_current_turn_rect = _turn_right_rect
	else: 
		_current_turn_rect = _default_rect
	
	if _spriteGFX:
		_spriteGFX.region_rect = _current_turn_rect
		_spriteGFX.region_enabled = true
	
	if _isPushedBack:
		ApplyCollisionBump()
	
	var nextPos: Vector3 = _mapPosition + ReturnVelocity()
	var nextPixelPos: Vector2i = Vector2i(ceil(nextPos.x), ceil(nextPos.z))
	
	# Wall collision handling
	if _collisionHandler and _collisionHandler.IsCollidingWithWall(Vector2i(ceil(nextPos.x), ceil(_mapPosition.z))):
		nextPos.x = _mapPosition.x 
		SetCollisionBump(Vector3(-sign(ReturnVelocity().x), 0, 0))
		_avoid_vector = Vector2(-sign(ReturnVelocity().x), 0)
		_avoid_timer = 1.0
	
	if _collisionHandler and _collisionHandler.IsCollidingWithWall(Vector2i(ceil(_mapPosition.x), ceil(nextPos.z))):
		nextPos.z = _mapPosition.z
		SetCollisionBump(Vector3(0, 0, -sign(ReturnVelocity().z)))
		_avoid_vector = Vector2(0, -sign(ReturnVelocity().z))
		_avoid_timer = 1.0

	position = Vector2(_mapPosition.x, _mapPosition.z)
	
	if _collisionHandler:
		HandleRoadType(nextPixelPos, _collisionHandler.ReturnCurrentRoadType(nextPixelPos))
	UpdateLapCount(nextPixelPos)
	SetMapPosition(nextPos)
	UpdateMovementSpeed()
	UpdateVelocity(mapForward)

func UpdateLapCount(current_position: Vector2i):
	if not _collisionHandler:
		return
		
	var current_road_type = _collisionHandler.ReturnCurrentRoadType(current_position)
	
	if current_road_type == Globals.RoadType.LAP_READER:
		if lap_check_cooldown <= 0 and !is_on_lap_reader:
			current_lap += 1
			emit_signal("lap_completed", current_lap)
			print("Bot lap completed! Current lap: ", current_lap)
			lap_check_cooldown = LAP_COOLDOWN_TIME
			is_on_lap_reader = true
	else:
		is_on_lap_reader = false
		
	if lap_check_cooldown > 0:
		lap_check_cooldown -= get_process_delta_time()
	
	last_lap_position = current_position

func _make_ai_decision():
	# Update current target waypoint
	_update_target_waypoint()
	
	# Handle avoidance timer
	if _avoid_timer > 0:
		_avoid_timer -= _decision_interval

func _update_target_waypoint():
	if _race_line_points.size() == 0:
		return
		
	# Find the closest waypoint ahead
	var current_pos = Vector2(_mapPosition.x, _mapPosition.z)
	var min_distance = INF
	var best_index = _current_target_index
	
	for i in range(_race_line_points.size()):
		var point = _race_line_points[i]
		var point_2d = Vector2(point.x, point.z)
		var distance = current_pos.distance_to(point_2d)
		
		if distance < min_distance:
			min_distance = distance
			best_index = i
	
	# Look ahead to the next waypoint
	_current_target_index = (best_index + 1) % _race_line_points.size()

func _calculate_ai_input() -> Vector2:
	var input = Vector2.ZERO
	
	if _race_line_points.size() == 0:
		# Fallback: just go forward
		input.y = -1.0 * _aggressiveness
		return input
	
	# Get target waypoint
	var target = _race_line_points[_current_target_index]
	var target_2d = Vector2(target.x, target.z)
	var current_2d = Vector2(_mapPosition.x, _mapPosition.z)
	
	# Calculate direction to target
	var direction_to_target = (target_2d - current_2d).normalized()
	
	# Convert to input (steering and throttle)
	input.x = direction_to_target.x * _steering_sensitivity
	input.y = -_aggressiveness  # Always try to go forward
	
	# Apply avoidance if needed
	if _avoid_timer > 0:
		input.x += _avoid_vector.x * 2.0
		input.y *= 0.5  # Slow down when avoiding
	
	# Add some randomness to make AI less perfect
	input.x += randf_range(-0.1, 0.1) * (2.0 - _aggressiveness)
	
	# Clamp input values
	input.x = clamp(input.x, -1.0, 1.0)
	input.y = clamp(input.y, -1.0, 1.0)
	
	return input

func set_difficulty(difficulty: float):
	# difficulty should be between 0 (easy) and 1 (hard)
	_aggressiveness = lerp(0.5, 1.3, difficulty)
	_decision_interval = lerp(0.5, 0.2, difficulty)
	_steering_sensitivity = lerp(1.0, 3.0, difficulty)
