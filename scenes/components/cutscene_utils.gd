extends Node2D

@onready var pos_override : Node2D = $PlayerPosOverride
@onready var particle_template : Sprite2D = $Particles

@export var zoom : float = 2.5

@onready var p_anim : Sprite2D = $PlayerPosOverride/AnimPreview
func _ready() -> void:
	p_anim.hide()
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

var camera_grabbed = false
func grab_camera():
	zoom = GAMESTATE.camera.zoom.x
	camera_grabbed = true

var player_following = false
func begin_player_follow():
	player_following = true

func end_player_follow():
	player_following = false
	GAMESTATE.player.play_walk()


func set_camera_override(node_name : String):
	CAMERA.follow_node = get_node(node_name)

func clear_camera_override():
	CAMERA.follow_node = GAMESTATE.player


func _process(_delta: float) -> void:
	if camera_grabbed:
		CAMERA.override_zoom = zoom
	if player_following:
		GAMESTATE.player.global_position = pos_override.global_position - Vector2(UTILS.tile_size / 2)
		GAMESTATE.player.pos = UTILS.to_grid(pos_override.global_position)
	if player_anim_grabbed:
		GAMESTATE.player.set_sprite(p_anim.frame)

@export var player_frame : int = 8
var player_anim_grabbed = false
func grab_player_anim():
	GAMESTATE.player.anim_paused = true
	player_anim_grabbed = true

func end_player_anim():
	player_anim_grabbed = false
