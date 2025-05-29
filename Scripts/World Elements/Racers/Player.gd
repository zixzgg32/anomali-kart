#Player.gd
extends Racer

var _default_rect := Rect2(10, 4, 53, 53) 
var _turn_left_rect := Rect2(295, 0, 65, 58) 
var _turn_right_rect := Rect2(228, 0, 65, 58) 
var _current_turn_rect := Rect2(10, 4, 53, 53)

func set_character_sprite(texture: Texture2D):
	if _spriteGFX and texture:
		_spriteGFX.texture = texture

func Setup(mapSize : int):
	SetMapSize(mapSize)
	_default_rect = Rect2(10, 4, 53, 53) 
	_turn_left_rect = Rect2(295, 0, 65, 58) 
	_turn_right_rect = Rect2(228, 0, 65, 58) 
	_current_turn_rect = _default_rect
func Update(mapForward : Vector3):
	var input = ReturnPlayerInput()
	if input.x < 0: 
		_current_turn_rect = _turn_left_rect
	elif input.x > 0: 
		_current_turn_rect = _turn_right_rect
	else: 
		_current_turn_rect = _default_rect
	if _spriteGFX:
		_spriteGFX.region_rect = _current_turn_rect
		_spriteGFX.region_enabled = true
	if(_isPushedBack):
		ApplyCollisionBump()
	var nextPos : Vector3 = _mapPosition + ReturnVelocity()
	var nextPixelPos : Vector2i = Vector2i(ceil(nextPos.x), ceil(nextPos.z))
	
	if(_collisionHandler.IsCollidingWithWall(Vector2i(ceil(nextPos.x), ceil(_mapPosition.z)))):
		nextPos.x = _mapPosition.x 
		SetCollisionBump(Vector3(-sign(ReturnVelocity().x), 0, 0))
	if(_collisionHandler.IsCollidingWithWall(Vector2i(ceil(_mapPosition.x), ceil(nextPos.z)))):
		nextPos.z = _mapPosition.z
		SetCollisionBump(Vector3(0, 0, -sign(ReturnVelocity().z)))
	
	HandleRoadType(nextPixelPos, _collisionHandler.ReturnCurrentRoadType(nextPixelPos))
	
	SetMapPosition(nextPos)
	UpdateMovementSpeed()
	UpdateVelocity(mapForward)

func ReturnPlayerInput() -> Vector2:
	_inputDir.x = Input.get_action_strength("Left") - Input.get_action_strength("Right")
	_inputDir.y = Input.get_action_strength("Backward") - Input.get_action_strength("Forward")
	if _inputDir.x != 0 or _inputDir.y != 0:
		print("Player Input: ", _inputDir, " | Current Position: ", _mapPosition)
	return Vector2(_inputDir.x, _inputDir.y)
