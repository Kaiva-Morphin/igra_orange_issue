extends Node

var tile_size : Vector2i = Vector2i(16, 16)
var speed_per_tile : float = 0.15

func to_grid(v: Vector2):
	return Vector2i(floor(v.x / tile_size.x), floor(v.y / tile_size.y))

func from_grid(v: Vector2i):
	return v * tile_size

func reverse_state(state: STRUCTS.WorldState):
	if state == STRUCTS.WorldState.Future:
		return STRUCTS.WorldState.Past
	return STRUCTS.WorldState.Future

func get_input_dir() -> Vector2i:
	# New first
	if Input.is_action_just_pressed("up"):
		return Vector2i(0, -1)
	if Input.is_action_just_pressed("down"):
		return Vector2i(0, 1)
	if Input.is_action_just_pressed("left"):
		return Vector2i(-1, 0)
	if Input.is_action_just_pressed("right"):
		return Vector2i(1, 0)
	
	if Input.is_action_pressed("up"):
		return Vector2i(0, -1)
	if Input.is_action_pressed("down"):
		return Vector2i(0, 1)
	if Input.is_action_pressed("left"):
		return Vector2i(-1, 0)
	if Input.is_action_pressed("right"):
		return Vector2i(1, 0)
	return Vector2i.ZERO

func tween_move(what: Node, dst: Vector2, on_end = null, time=speed_per_tile):
	var tween := get_tree().create_tween()
	tween.tween_property(what, "position", dst, time)
	if on_end: tween.finished.connect(on_end)


func log_print(msg):
	if OS.is_debug_build():
		print(msg)

func log_prints(...msg):
	if OS.is_debug_build():
		prints(msg)
