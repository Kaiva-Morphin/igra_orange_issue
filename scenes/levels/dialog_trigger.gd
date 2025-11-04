extends Area2D

@export var dialog_name : String


func _ready():
	self.body_entered.connect(self._on_body_entered)

var shooted = false
func _on_body_entered(body):
	if shooted: return
	shooted = true
	if body.is_in_group("player"):
		GAMESTATE.canvas.start_dialog(DIALOGS.dialogs[dialog_name])
