extends Node2D

var shooted = false
func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body.is_in_group("player"): return
	if shooted : return
	shooted = true
	$TimeMachine/AnimationPlayer.play("Run")

@export var tp_pos : Node2D
func tp():
	GAMESTATE.player.pos = UTILS.to_grid(tp_pos.global_position)
	GAMESTATE.player.global_position = UTILS.from_grid(GAMESTATE.player.pos)