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
	GAMESTATE.vignette.animate(0.0, 0.3, 5.0, Vector4(1.0, 1.0, 1.0, 1.0))
	var music: AudioStreamPlayer = GAMESTATE.level_ref.theme_music
	music.volume_db = -40
	music.play()
	var tween = create_tween()
	tween.tween_property(music, "volume_db", -15, 4.0)

func suppress_player():
	GAMESTATE.player.suppressed = true


func unsuppress_player():
	GAMESTATE.player.suppressed = false