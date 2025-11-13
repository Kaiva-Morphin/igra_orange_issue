extends Control


@onready var powers = $Powers

#
#func _update_joystick(pointer_pos: Vector2):
	#var raw := pointer_pos - joy_center
	#var clamped := Vector2(clamp(raw.x, -joy_radius, joy_radius), clamp(raw.y, -joy_radius, joy_radius))
	#output_vec = clamped / joy_radius
	#thumb.position = joy_center + clamped - thumb.size * 0.5
#
#
#func _reset_joystick():
	#output_vec = Vector2.ZERO
	#thumb.position = joy_center - thumb.size * 0.5


#func _unhandled_input(event):
	#if event is InputEventScreenDrag or event is InputEventScreenTouch:
		#if event.pressed or event is InputEventScreenDrag:
			#_update_joystick(event.position)
		#else:
			#_reset_joystick()

@onready var controller : TextureButton = $InputCross

func _ready() -> void:
	self.visible = GAMESTATE.touch_enabled

func _on_meow_pressed() -> void:
	GAMESTATE.touch_meow_just_pressed = true

func _on_rewind_pressed() -> void:
	GAMESTATE.touch_rewind_just_pressed = true

func _on_fast_rewind_pressed() -> void:
	GAMESTATE.touch_fastrewind_just_pressed = true

func _on_back_pressed() -> void:
	GAMESTATE.touch_back_just_pressed = true

func _on_swap_pressed() -> void:
	GAMESTATE.touch_swap_just_pressed = true


var input_vec := Vector2.ZERO
var pressed = false
func _on_input_cross_gui_input(event: InputEvent) -> void:
	var rect := controller.get_rect()
	if event is InputEventMouseButton:
		pressed = event.pressed
		if event.pressed:
			var v = rect.size / 2 - event.position
			input_vec = get_dominant_axis(v)
		else:
			input_vec = Vector2.ZERO
	if event is InputEventMouseMotion && pressed:
		var v = rect.size / 2 - event.position
		input_vec = get_dominant_axis(v)

func get_dominant_axis(vec: Vector2) -> Vector2:
	var deadzone = 10.0
	if abs(vec.x) < deadzone and abs(vec.y) < deadzone:
		return Vector2.ZERO
	if abs(vec.x) > abs(vec.y):
		return -Vector2(sign(vec.x), 0)
	else:
		return -Vector2(0, sign(vec.y))
