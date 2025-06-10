#Racer.gd
class_name Racer
extends WorldElement

var _inputDir : Vector2 = Vector2.ZERO

@export_category("Racer Movement Settings")
@export var _maxMovementSpeed : float = 120
@export var _movementAccel : float = 70
@export var _movementDeaccel : float = 120
var _currentMoveDirection : int = 0.0
var _movementSpeed : float = 0.0
var _speedMultiplier : float = 1.0
var _velocity : Vector3 = Vector3.ZERO
var _onRoadType : Globals.RoadType = Globals.RoadType.VOID

@export_category("Racer Collision Settings")
@export var _collisionHandler : Node
var _bumpDir : Vector3 = Vector3.ZERO
var _isPushedBack : bool = false
var _pushbackTime : float = 0.3
var _currPushbackTime : float = 0.0
var _bumpIntensity : float = 2

func ReturnMovementSpeed() -> float: return _movementSpeed 
func ReturnCurrentMoveDirection() -> int: return _currentMoveDirection

func UpdateVelocity(mapForward : Vector3):
	_velocity = Vector3.ZERO
	if(_movementSpeed == 0): return
	var forward : Vector3 = mapForward * _currentMoveDirection
	_velocity = (forward * _movementSpeed) * get_process_delta_time()
func ReturnVelocity() -> Vector3: return _velocity

func HandleRoadType(nextPixelPos : Vector2i, roadType : Globals.RoadType):
	print("HandleRoadType: ", roadType, " at ", nextPixelPos, " Track: ", Globals.selected_track_index)
	if(roadType == _onRoadType): return
	_onRoadType = roadType
	
	# CRITICAL FIX: Ensure sprite is always visible by default
	if _spriteGFX and is_instance_valid(_spriteGFX):
		_spriteGFX.self_modulate.a = 1.0
	
	match roadType:
		Globals.RoadType.VOID:
			print("WARNING: VOID detected at ", nextPixelPos, " - Track ", Globals.selected_track_index)
			
			# Check if we're near the starting position for current track
			var current_track = Globals.selected_track_index
			if current_track >= 0 and current_track < 4:
				var start_positions = [
					Vector3(378, 0, 434),      # Track 0
					Vector3(436.579, 0, 650.6988),  # Track 1
					Vector3(111.5937, 0, 294.0043), # Track 2
					Vector3(484.6098, 0.0, 661.0996) # Track 3
				]
				var start_pos = start_positions[current_track]
				var distance_from_start = Vector2(nextPixelPos.x - start_pos.x, nextPixelPos.y - start_pos.z).length()
				
				if distance_from_start < 100:
					print("Near starting position, treating VOID as ROAD")
					_speedMultiplier = 1.0
				else:
					# Make semi-transparent instead of invisible
					if _spriteGFX and is_instance_valid(_spriteGFX):
						_spriteGFX.self_modulate.a = 0.5
					_speedMultiplier = 0.3  # Slow down but don't stop
			else:
				_speedMultiplier = 0.5
				
		Globals.RoadType.ROAD:
			_speedMultiplier = 1.0
			
		Globals.RoadType.GRAVEL:
			_speedMultiplier = 0.9
			
		Globals.RoadType.OFF_ROAD:
			_speedMultiplier = 0.9
			
		Globals.RoadType.SINK:
			# Make semi-transparent instead of invisible
			if _spriteGFX and is_instance_valid(_spriteGFX):
				_spriteGFX.self_modulate.a = 0.3
			_speedMultiplier = 0.1
			
		Globals.RoadType.WALL:
			# Don't change speed multiplier for walls
			pass
			
		Globals.RoadType.LAP_READER:
			print("On LAP_READER (finish/start line) - ensuring full functionality")
			if _spriteGFX and is_instance_valid(_spriteGFX):
				_spriteGFX.self_modulate.a = 1.0
			_speedMultiplier = 1.0
	
	# Final safety check - never let speed multiplier go to 0 unless explicitly intended
	if _speedMultiplier <= 0:
		print("WARNING: Speed multiplier was 0! Setting to minimum. Roadtype: ", roadType)
		_speedMultiplier = 0.1

func ReturnOnRoadType() -> Globals.RoadType: return _onRoadType

func UpdateMovementSpeed():
	if(_inputDir.y != 0):
		if(_inputDir.y != _currentMoveDirection and _movementSpeed > 0): Deaccelerate()
		else: Accelerate()
	else:
		if(abs(_movementSpeed) > 0): Deaccelerate()

func Accelerate():
	_movementSpeed += _movementAccel * get_process_delta_time()
	_movementSpeed = min(_movementSpeed, _maxMovementSpeed * _speedMultiplier)
	if(_currentMoveDirection == _inputDir.y): return
	_currentMoveDirection = _inputDir.y

func Deaccelerate():
	_movementSpeed -= _movementDeaccel * get_process_delta_time()
	_movementSpeed = max(_movementSpeed, 0)
	if(_movementSpeed == 0 and _currentMoveDirection != _inputDir.y):
		_currentMoveDirection = _inputDir.y

func SetCollisionBump(bumpDir : Vector3):
	if(!_isPushedBack):
		_bumpDir = bumpDir
		_isPushedBack = true
		_currPushbackTime = _pushbackTime

func get_movement_speed() -> float:
	return _movementSpeed
	
func ApplyCollisionBump():
	_currPushbackTime -= get_process_delta_time()
	if(_currPushbackTime <= 0.0):
		_isPushedBack = false
	else:
		var bumpVelocity : Vector3 = _bumpDir * (_bumpIntensity * (_currPushbackTime / _pushbackTime))
		Deaccelerate()
		SetMapPosition(_mapPosition + bumpVelocity)
