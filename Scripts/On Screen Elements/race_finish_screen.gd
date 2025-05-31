# RaceFinishScreen.gd
extends Control

@onready var result_label: Label = $VBoxContainer/ResultLabel
@onready var rematch_button: Button = $VBoxContainer/ButtonContainer/RematchButton
@onready var menu_button: Button = $VBoxContainer/ButtonContainer/MenuButton
@onready var background: ColorRect = $Background

signal rematch_requested
signal menu_requested

func _ready():
	hide()
	await get_tree().process_frame
	var vbox = $VBoxContainer
	vbox.anchor_left = 0.5
	vbox.anchor_top = 0.5
	vbox.anchor_right = 0.5
	vbox.anchor_bottom = 0.5
	vbox.pivot_offset = Vector2(vbox.size.x / 2, vbox.size.y / 2)
	vbox.position = Vector2(0, 0)

	rematch_button.pressed.connect(_on_rematch_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func show_race_result(position: int):
	var position_text = ""
	match position:
		1:
			position_text = "1st Place!"
			result_label.modulate = Color.GOLD
		2:
			position_text = "2nd Place!"
			result_label.modulate = Color.SILVER
		3:
			position_text = "3rd Place!"
			result_label.modulate = Color(0.8, 0.5, 0.2) # Bronze
		_:
			position_text = str(position) + "th Place"
			result_label.modulate = Color.WHITE
	
	result_label.text = "Race Finished!\n" + position_text
	show()
	
	# Animate the appearance
	var tween = create_tween()
	tween.set_parallel(true)
	modulate.a = 0
	scale = Vector2(0.5, 0.5)
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.5).set_trans(Tween.TRANS_BACK)

func _on_rematch_pressed():
	emit_signal("rematch_requested")

func _on_menu_pressed():
	emit_signal("menu_requested")
