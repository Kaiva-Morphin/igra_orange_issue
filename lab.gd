extends Node2D

func _ready() -> void:
	var pos = UTILS.to_grid(global_position)
	global_position = Vector2(UTILS.from_grid(pos)) - Vector2(UTILS.tile_size) * 0.5
	for s in $Sounds.get_children():
		s.play()

var i = false
func _process(_dt: float) -> void:
	if !i:
		i = true
		GAMESTATE.player.look_down()
