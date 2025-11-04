extends Node2D
@export var tp_pos : Node2D

func tp():
	GAMESTATE.player.pos = UTILS.to_grid(tp_pos.global_position)
	GAMESTATE.player.global_position = UTILS.from_grid(GAMESTATE.player.pos)
	GAMESTATE.vignette.animate(0.0, 0.3, 5.0, Vector4(1.0, 1.0, 1.0, 1.0))
	var music: AudioStreamPlayer = GAMESTATE.level_ref.theme_music
	music.volume_db = -15
	var tween = create_tween()
	tween.tween_property(music, "volume_db", -40, 2.0)
	