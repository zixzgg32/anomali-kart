#Player.gd
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
var last_checkpoint_position: Vector2i
var has_passed_checkpoint: bool = false
var required_checkpoint: Vector2i 
var last_direction: Vector2i = Vector2i.ZERO
const LAP_COOLDOWN_TIME := 0.5 

var can_move := false

func set_character_sprite(texture: Texture2D):
	if _spriteGFX and texture:
		_spriteGFX.texture = texture

func _ready():
	add_to_group("player")
	# Connect to countdown finished signal with a delay to ensure the countdown node exists
	call_deferred("_connect_to_countdown")

func _connect_to_countdown():
	# Wait a bit longer for countdown to be ready
	await get_tree().process_frame
	await get_tree().process_frame
	
	var countdown_nodes = get_tree().get_nodes_in_group("countdown")
	print("Found countdown nodes: ", countdown_nodes.size())
	
	if countdown_nodes.size() > 0:
		var countdown = countdown_nodes[0]
		if countdown.has_signal("countdown_finished"):
			if not countdown.is_connected("countdown_finished", _on_countdown_finished):
				countdown.connect("countdown_finished", _on_countdown_finished)
				print("Connected to countdown signal")
			else:
				print("Already connected to countdown")
		else:
			print("Countdown node doesn't have countdown_finished signal")
	else:
		# If no countdown found, allow movement immediately for testing
		print("No countdown found, allowing movement")
		can_move = true

func _on_countdown_finished():
	can_move = true
	print("Countdown finished! Player can now move.")

func Setup(mapSize : int):
	SetMapSize(mapSize)
	_default_rect = Rect2(10, 4, 53, 53) 
	_turn_left_rect = Rect2(295, 0, 65, 58) 
	_turn_right_rect = Rect2(228, 0, 65, 58) 
	_current_turn_rect = _default_rect
	
	print("Player Setup completed for track: ", Globals.selected_track_index)
	print("Player starting position: ", _mapPosition)
	
func Update(mapForward : Vector3):
	# Always get input first, then check if we can move
	ReturnPlayerInput()
	
	if not can_move:
		# Still process input but don't move
		_inputDir = Vector2.ZERO
		return
		
	# Visual feedback for turning
	if _inputDir.x < 0: 
		_current_turn_rect = _turn_left_rect
	elif _inputDir.x > 0: 
		_current_turn_rect = _turn_right_rect
	else: 
		_current_turn_rect = _default_rect
		
	if _spriteGFX:
		_spriteGFX.region_rect = _current_turn_rect
		_spriteGFX.region_enabled = true
		
		# CRITICAL FIX: Ensure sprite remains visible during gameplay
		if _spriteGFX.self_modulate.a < 0.1:
			print("WARNING: Sprite alpha too low, forcing visibility")
			_spriteGFX.self_modulate.a = 1.0
		
	if(_isPushedBack):
		ApplyCollisionBump()
		
	var nextPos : Vector3 = _mapPosition + ReturnVelocity()
	var nextPixelPos : Vector2i = Vector2i(ceil(nextPos.x), ceil(nextPos.z))
	
	# Wall collision check
	if(_collisionHandler and _collisionHandler.IsCollidingWithWall(Vector2i(ceil(nextPos.x), ceil(_mapPosition.z)))):
		nextPos.x = _mapPosition.x 
		SetCollisionBump(Vector3(-sign(ReturnVelocity().x), 0, 0))
	if(_collisionHandler and _collisionHandler.IsCollidingWithWall(Vector2i(ceil(_mapPosition.x), ceil(nextPos.z)))):
		nextPos.z = _mapPosition.z
		SetCollisionBump(Vector3(0, 0, -sign(ReturnVelocity().z)))
		
	# Get road type and handle it
	var current_road_type = _collisionHandler.ReturnCurrentRoadType(nextPixelPos)
	HandleRoadType(nextPixelPos, current_road_type)
	UpdateLapCount(nextPixelPos)
	SetMapPosition(nextPos)
	UpdateMovementSpeed()
	UpdateVelocity(mapForward)
	
	# Safety check for movement issues
	if _speedMultiplier <= 0 and (_inputDir.x != 0 or _inputDir.y != 0):
		print("ERROR: Trying to move but speed multiplier is 0! Road type: ", current_road_type)

func UpdateLapCount(current_position: Vector2i):
	var current_road_type = _collisionHandler.ReturnCurrentRoadType(current_position)
	if current_road_type == Globals.RoadType.LAP_READER && !is_on_lap_reader:
		if lap_check_cooldown <= 0:
			current_lap += 1
			emit_signal("lap_completed", current_lap)
			print("Lap completed! Current lap: ", current_lap)
			lap_check_cooldown = LAP_COOLDOWN_TIME
			
			if current_lap >= 4:
				_finish_race()
				
	is_on_lap_reader = (current_road_type == Globals.RoadType.LAP_READER)
	if lap_check_cooldown > 0:
		lap_check_cooldown -= get_process_delta_time()
	last_lap_position = current_position
	
func _finish_race():
	print("Race finished!")
	can_move = false
	get_tree().call_group("game_manager", "_on_race_finished", 1)
	
func ReturnPlayerInput() -> Vector2:
	# Always get input, regardless of can_move state
	var input_x = Input.get_action_strength("Left") - Input.get_action_strength("Right")
	var input_y = Input.get_action_strength("Backward") - Input.get_action_strength("Forward")
		
	if can_move:
		_inputDir.x = input_x
		_inputDir.y = input_y
		
	return Vector2(_inputDir.x, _inputDir.y)
