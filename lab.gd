extends Node2D

func _ready() -> void:
	var pos = UTILS.to_grid(global_position)
	global_position = Vector2(UTILS.from_grid(pos)) - Vector2(UTILS.tile_size) * 0.5
	

var i = false
func _process(_dt: float) -> void:
	if !i:
		i = true
		GAMESTATE.player.look_down()

func _on_room_body_entered(body):
	if !body.is_in_group("player"): return
	for s in $Sounds.get_children():
		s.play()