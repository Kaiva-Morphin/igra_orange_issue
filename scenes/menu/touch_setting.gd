extends CheckButton


func _ready() -> void:
	self.button_pressed = GAMESTATE.touch_enabled


func _on_toggled(toggled_on: bool) -> void:
	GAMESTATE.touch_enabled = toggled_on
	if GAMESTATE.canvas != null:
		GAMESTATE.canvas.touch.visible = toggled_on
