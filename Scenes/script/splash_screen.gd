extends Control

@export var next_scene: PackedScene
@export var fade_duration: float = 1.0
@export var display_time: float = 2.0
@export var texture_rect: TextureRect
@export var textures: Array[Texture2D] = []

var current_texture_index := 0
var skipping := false 

func _ready():
	modulate = Color(1, 1, 1, 0)
	if texture_rect:
		texture_rect.modulate = Color.WHITE
	if textures.size() > 0:
		change_texture(textures[current_texture_index])
	fade_in()

func _unhandled_input(event):
	if event.is_action_pressed("ui_accept") and not skipping:
		skipping = true
		change_scene()

func fade_in():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)
	tween.finished.connect(fade_out)

func fade_out():
	await get_tree().create_timer(display_time).timeout

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	await tween.finished

	if skipping: return  

	current_texture_index += 1
	if current_texture_index < textures.size():
		change_texture(textures[current_texture_index])
		fade_in()
	else:
		change_scene()

func change_scene():
	get_tree().change_scene_to_packed(next_scene)

func change_texture(new_texture: Texture2D):
	if texture_rect:
		texture_rect.texture = new_texture
		texture_rect.modulate = Color.WHITE
