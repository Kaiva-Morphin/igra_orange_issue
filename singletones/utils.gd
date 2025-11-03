extends Node

var tile_size : Vector2i = Vector2i(16, 16)
var speed_per_tile : float = 0.15
var walk_anim_speed = 2.5
var input_delay = 0.175
var transition = Tween.TRANS_LINEAR
func to_grid(v: Vector2):
	return Vector2i(floor(v.x / tile_size.x), floor(v.y / tile_size.y))

func from_grid(v: Vector2i):
	return v * tile_size

func reverse_state(state: STRUCTS.WorldState):
	if state == STRUCTS.WorldState.Future:
		return STRUCTS.WorldState.Past
	return STRUCTS.WorldState.Future

# func get_input_dir() -> Vector2i:
# 	# New first
# 	if Input.is_action_just_pressed("up"):
# 		return Vector2i(0, -1)
# 	if Input.is_action_just_pressed("down"):
# 		return Vector2i(0, 1)
# 	if Input.is_action_just_pressed("left"):
# 		return Vector2i(-1, 0)
# 	if Input.is_action_just_pressed("right"):
# 		return Vector2i(1, 0)
	
# 	if Input.is_action_pressed("up"):
# 		return Vector2i(0, -1)
# 	if Input.is_action_pressed("down"):
# 		return Vector2i(0, 1)
# 	if Input.is_action_pressed("left"):
# 		return Vector2i(-1, 0)
# 	if Input.is_action_pressed("right"):
# 		return Vector2i(1, 0)
# 	return Vector2i.ZERO

func tween_move(what: Node, dst: Vector2, on_end = null, time=speed_per_tile):
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(what, "global_position", dst, time)
	if on_end: tween.finished.connect(on_end)

# var tween_proxies := {} # what -> proxy

# func tween_move(what: Node2D, dst: Vector2, on_end = null, time = speed_per_tile):
# 	var proxy := Node2D.new()
# 	proxy.position = what.global_position
# 	get_tree().current_scene.add_child(proxy)

# 	tween_proxies[what] = {
# 		"proxy": proxy,
# 		"on_end": on_end
# 	}

# 	var tween := get_tree().create_tween()
# 	tween.tween_property(proxy, "global_position", dst, time)
# 	tween.finished.connect(func():
# 		if on_end:
# 			on_end.call()
# 		tween_proxies.erase(what)
# 		proxy.queue_free()
# 	)

# func update_tween_positions():
# 	for what in tween_proxies.keys():
# 		var proxy_data = tween_proxies[what]
# 		var proxy = proxy_data["proxy"]
# 		what.global_position = proxy.global_position


func log_print(msg):
	if OS.is_debug_build(): 
		print(msg)

func log_prints(...msg):
	if OS.is_debug_build():
		prints(msg)

func dir_to_anim(dir: Vector2i):
	if dir.x == 0 and dir.y == -1:
		return "up"
	if dir.x == 0 and dir.y == 1:
		return "down"
	if dir.x == -1 and dir.y == 0:
		return "left"
	if dir.x == 1 and dir.y == 0:
		return "right"
	return null

var _press_times := {
	"up": -1.0,
	"down": -1.0,
	"left": -1.0,
	"right": -1.0,
}

func _process(_delta):
	_update_press_times()


func _update_press_times():
	for action in _press_times.keys():
		if Input.is_action_just_pressed(action):
			_press_times[action] = Time.get_ticks_msec() / 1000.0  # секунды
		elif Input.is_action_just_released(action):
			_press_times[action] = -1.0


func get_input_dir() -> Vector2i:
	var active := []
	for action in _press_times.keys():
		if Input.is_action_pressed(action):
			active.append(action)

	if active.is_empty():
		return Vector2i.ZERO

	# Выбираем последнюю нажатую клавишу
	var last_action = active[0]
	for action in active:
		if _press_times[action] > _press_times[last_action]:
			last_action = action

	match last_action:
		"up":
			return Vector2i(0, -1)
		"down":
			return Vector2i(0, 1)
		"left":
			return Vector2i(-1, 0)
		"right":
			return Vector2i(1, 0)
	return Vector2i.ZERO


func get_hold_time(action: String) -> float:
	# Возвращает время удержания в секундах
	if _press_times[action] < 0.0:
		return 0.0
	return (Time.get_ticks_msec() / 1000.0) - _press_times[action]
