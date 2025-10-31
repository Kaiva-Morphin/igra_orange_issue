extends Node2D


@onready var player = $Player
@onready var anims = $AnimationPlayer

@onready var past : TileMapLayer = $Past
@onready var future : TileMapLayer = $Future
var in_future = true

var in_move = false
var next_move = null
var swap_requested = false

var fp_offset = 0;

func _ready() -> void:
	var f_tiles = future.get_used_cells()
	for tile_pos in f_tiles:
		var ac : Vector2i = future.get_cell_atlas_coords(tile_pos)
		var source_id = future.get_cell_source_id(tile_pos)
		past.set_cell(tile_pos, source_id, ac + Vector2i(0, -1))
	
	var all = {}
	
	var swaps = {}
	for node in get_tree().get_nodes_in_group("swap_collider"):
		swaps[node.get_instance_id()] = node
		all[node.get_instance_id()] = node
	var movables = {}
	for node in get_tree().get_nodes_in_group("movable"):
		movables[node.get_instance_id()] = node
		all[node.get_instance_id()] = node
	for node in all.values():
		var p = UTILS.to_grid(node.position);
		if movables.has(node.get_instance_id()):
			GAMESTATE.set_movable_collider(node, p)
			prints(node.name, "will be movable")
		elif swaps.has(node.get_instance_id()):
			prints(node.name, "will be swap")
			GAMESTATE.set_swap_collider(node, p)
	get_tree().call_group("gamestate_reaction", "_on_gamestate_ready")



func swap():
	swap_requested = false
	if in_future:
		anims.play("ToPast")
	else:
		anims.play("ToFuture")
	in_future = !in_future
	get_tree().call_group("swap_reaction", "swap", in_future)

func can_swap_now() -> bool:
	var p = UTILS.to_grid(player.position)
	if GAMESTATE.get_swap_collider(p):
		return false
	return true

func _process(_dt: float) -> void:
	if swap_requested and can_swap_now():
		swap()
	if Input.is_action_just_pressed("swap"):
		if in_move:
			swap_requested = true
		elif can_swap_now():
			swap()
	if in_move:
		# todo: next_move?
		return
	var i_dir = get_input_dir()
	if i_dir == Vector2i.ZERO:
		return
	var pp = Vector2i(player.position)
	var dir = UTILS.tile_size * i_dir
	var m_pos_grid = UTILS.to_grid(pp + dir)
	var m = GAMESTATE.get_movable_collider(m_pos_grid)
	if m and m.is_movable():
		var m_target = pp + dir * 2
		var m_target_grid = UTILS.to_grid(m_target)
		var c = GAMESTATE.get_collider(m_target_grid)
		if (c and c.is_swap_collider_now()) or is_wall(m_target_grid):
			print("swap_collider blocked by wall or another collider")
			return
		m = GAMESTATE.pop_movable_collider(m_pos_grid)
		GAMESTATE.set_movable_collider(m, m_target_grid)
		tween_move(m, m_target)
	var s = GAMESTATE.get_swap_collider(m_pos_grid)
	if s and s.is_swap_collider_now():
		return
	var dst = pp + dir
	var cell = future.local_to_map(dst)
	var tile : TileData = future.get_cell_tile_data(cell)
	print("Moving")
	if tile and tile.get_collision_polygons_count(0):
		print("Blocked by wall")
		return
	in_move = true
	tween_move(player, dst, func(): in_move = false)

func is_wall(p: Vector2i):
	var cell = future.local_to_map(UTILS.from_grid(p))
	var tile : TileData  = future.get_cell_tile_data(cell)
	return tile and tile.get_collision_polygons_count(0)


func tween_move(what: Node, dst: Vector2, onend = null, time=0.2):
	var tween := get_tree().create_tween()
	tween.tween_property(what, "position", dst, time)
	if onend: tween.finished.connect(onend)

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





















#
