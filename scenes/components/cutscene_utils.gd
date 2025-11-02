extends Node2D

@onready var camera_override : Node2D = $CameraOverride
@onready var particle_template : Sprite2D = $Particles

func _ready() -> void:
	particle_template.hide()

func shoot_particle_effect():
	return

func shoot_particle_effect_player(idx: int, initial_offset: Vector2, dir: Vector2, lifetime: float):
	var p = particle_template.duplicate()
	add_child(p)
	p.global_position = GAMESTATE.player.global_position + initial_offset
	p.show()
	p.frame = idx
	UTILS.tween_move(p, GAMESTATE.player.global_position + dir + initial_offset, func(): p.queue_free(), lifetime)
	return
