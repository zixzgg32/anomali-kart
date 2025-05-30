#Pseudo3D.gd
extends Sprite2D

@export_category("Map Settings : Rotation")
@export var _mapStartRotationAngle : Vector2
@export var _mapMaxRotationSpeed : float
@export var _mapAccelRotationSpeed : float
@export var _mapDeaccelRotationSpeed : float
@export var _rotationRadius : float
var _mapRotSpeed : float
var _currRotDir = 0


@export_category("Map Settings : Position")
@export var _mapVerticalPosition : float
var _mapPosition : Vector3
var _mapRotationAngle : Vector2
var _finalMatrix : Basis

#@export_category("Rubber Band Settings")
#@export var min_scale_distance : float = 10.0  
#@export var max_scale_distance : float = 50.0 
#@export var min_scale : float = 0.5          
#@export var max_scale : float = 1.2         

#var _player : Racer
#var _ai_racers := []



func Setup(screenSize : Vector2, player : Racer):
	scale = screenSize / texture.get_size().x
	_mapPosition = Vector3(player.ReturnMapPosition().x, _mapVerticalPosition, player.ReturnMapPosition().z)
	_mapRotationAngle = _mapStartRotationAngle
	KeepRotationDistance(player)
	UpdateShader()

#func AddAIRacer(ai_racer: Racer):
	#_ai_racers.append(ai_racer)

func Update(player : Racer):
	RotateMap(player.ReturnPlayerInput().x, player.ReturnMovementSpeed())
	KeepRotationDistance(player)
	UpdateShader()

	#_update_racer_scales()
func RotateMap(rotDir : int, speed : float):
	if(rotDir != 0 and abs(speed) > 0): AccelMapRotation(rotDir)
	else: DeaccelMapRotation()
	
	if(abs(_mapRotSpeed) > 0):
		var incrementAngle : float = _currRotDir * _mapRotSpeed * get_process_delta_time()
		_mapRotationAngle.y += incrementAngle
		_mapRotationAngle.y = WrapAngle(_mapRotationAngle.y)
#func _update_racer_scales():
	#if not _player:
		#return
	#
	#var player_pos := Vector2(_player.ReturnMapPosition().x, _player.ReturnMapPosition().z)
	#
	#for ai: Node in _ai_racers:
		#if not is_instance_valid(ai):
			#continue
			#
		#var ai_pos := Vector2(ai.ReturnMapPosition().x, ai.ReturnMapPosition().z)
		#var distance: float = player_pos.distance_to(ai_pos)
		#
		## Calculate scale based on distance (inverse relationship)
		#var t: float = inverse_lerp(min_scale_distance, max_scale_distance, distance)
		#t = clamp(t, 0.0, 1.0)
		#var target_scale: float = lerp(max_scale, min_scale, t)
		#
		## Apply scale to AI's sprite
		#var sprite_gfx: Node = ai.get_node("SpriteGFX")
		#if sprite_gfx:
			#sprite_gfx.scale = Vector2(target_scale, target_scale)
		#
		## Optional: Also adjust speed based on distance (rubber band AI)
		#if ai.has_method("set_rubber_band_speed"):
			#var speed_factor: float = lerp(1.3, 0.7, t)  # Faster when far, slower when close
			#ai.set_rubber_band_speed(speed_factor)
func AccelMapRotation(rotDir : int):
	if(rotDir != _currRotDir and _mapRotSpeed > 0):
		DeaccelMapRotation()
		if(_mapRotSpeed == 0): _currRotDir = rotDir
	else:
		_mapRotSpeed += _mapAccelRotationSpeed * get_process_delta_time()
		_mapRotSpeed = min(_mapRotSpeed, _mapMaxRotationSpeed)
		_currRotDir = rotDir

func DeaccelMapRotation():
	if(abs(_mapRotSpeed) > 0):
		_mapRotSpeed -= _mapDeaccelRotationSpeed * get_process_delta_time()
		_mapRotSpeed = max(_mapRotSpeed, 0)

func KeepRotationDistance(racer : Racer):
	var relPos : Vector3 = Vector3((_rotationRadius / texture.get_size().x) * sin(_mapRotationAngle.y), 
									_mapPosition.y - racer.ReturnMapPosition().y, 
									(_rotationRadius / texture.get_size().x) * cos(_mapRotationAngle.y))
	_mapPosition = racer.ReturnMapPosition() + relPos

func UpdateShader():
	var yawMatrix : Basis = Basis(
		Vector3(cos(_mapRotationAngle.y), -sin(_mapRotationAngle.y), 0.0),
		Vector3(sin(_mapRotationAngle.y), cos(_mapRotationAngle.y), 0.0),
		Vector3(0.0,0.0,1.0)
	)
	
	var pitchMatrix : Basis = Basis(
		Vector3(1, 0 , 0),
		Vector3(0, cos(_mapRotationAngle.x), -sin(_mapRotationAngle.x)),
		Vector3(0, sin(_mapRotationAngle.x), cos(_mapRotationAngle.x))
	)
	
	var rotationMatrix : Basis = yawMatrix * pitchMatrix
	
	var translationMatrix : Basis = Basis(
		Vector3(1.0, 0.0, 0.0),
		Vector3(0.0, 1.0, 0),
		Vector3(_mapPosition.x * exp(_mapPosition.y), _mapPosition.z * exp(_mapPosition.y), exp(_mapPosition.y))
	)
	
	_finalMatrix =  translationMatrix * rotationMatrix 
	material.set_shader_parameter("mapMatrix", _finalMatrix)

func WrapAngle(angle : float) -> float: 
	if(rad_to_deg(angle) > 360):
		return angle - deg_to_rad(360)
	elif(rad_to_deg(angle) < 0):
		return angle + deg_to_rad(360)
	return angle

func ReturnForward() -> Vector3: return Vector3(sin(_mapRotationAngle.y), 0, cos(_mapRotationAngle.y))
func ReturnWorldMatrix() -> Basis: return _finalMatrix
func ReturnMapRotation() -> float: return _mapRotationAngle.y
