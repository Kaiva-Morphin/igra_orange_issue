extends STRUCTS.MovableCollider

@onready var sprite = $Sprite2D
@onready var reflection = $Sprite2D2

func _init() -> void:
	super._init(0)

func _level_ready(level: Level, push_initial: bool = true):
	pos = UTILS.to_grid(global_position)
	global_position = UTILS.from_grid(pos)
	super._level_ready(level, push_initial)
	process_swap(GAMESTATE.worldstate)

func add_collider_to_store():
	level_ref.mouse_collider_store.add_collider(self)

func on_swap(world_state: WorldState, push_step_needed : bool = true):
	if push_step_needed:
		push_step()
	super.on_swap(world_state, push_step_needed)

	process_swap(world_state)
	if world_state == STRUCTS.WorldState.Future && (GAMESTATE.player.pos - pos).length() <= 1:
		react_player(GAMESTATE.player.pos, true)
		

func save_state() -> StateData:
	var s = super.save_state()
	s.data["frame"] = sprite.frame
	return s

func restore_state(old_state: StateData):
	super.restore_state(old_state)
	pos = old_state.data["pos"]
	sprite.frame = old_state.data["frame"]
	global_position = UTILS.from_grid(pos)
	process_swap(GAMESTATE.worldstate)

func get_mask(_world: WorldState) -> int:
	if _world == STRUCTS.WorldState.Future:
		return 0
	else:
		return STATE_COLLIDER_PLAYER_MASK | STATE_COLLIDER_MOVABLE_MASK
	
func process_swap(world_state: WorldState):
	mask = get_mask(world_state)
	if world_state == STRUCTS.WorldState.Future:
		sprite.frame = 0
		reflection.frame = 0
	else:
		if mask == 0:
			sprite.frame = 3
			reflection.frame = 3
		else:
			sprite.frame = 4
			reflection.frame = 4

func react_player(next_player_pos: Vector2i, unchecked = false) -> float:
	if GAMESTATE.worldstate == STRUCTS.WorldState.Past && !unchecked:
		return -1
	var to_check = [
		pos,
		pos + Vector2i(1, 0),
		pos + Vector2i(-1, 0),
		pos + Vector2i(0, 1),
		pos + Vector2i(0, -1)
	]

	to_check.sort_custom(func(a, b):
		return a.distance_squared_to(next_player_pos) > b.distance_squared_to(next_player_pos)
	)
	var dst = null
	for d in to_check:
		if d == next_player_pos:
			continue
		if level_ref.movable_collider_store.is_occupied_for(d, STATE_COLLIDER_MOVABLE_MASK):
			continue
		if level_ref.static_collider_store.is_occupied_for(d, STATE_COLLIDER_MOVABLE_MASK):
			continue
		if level_ref.mouse_collider_store.get_collider(d):
			continue
		dst = d
		break

	if dst == null:
		return -1
	
	var dir = dst - pos
	# var i = level_ref.ice_store.get_collider(dst)
	# if i and GAMESTATE.worldstate == WorldState.Past:
	# 	dst = level_ref.get_slide_end(dst, player_dir)
	# 	var d = dst - pos
	# 	var dist = max(abs(d.x), abs(d.y))
	# 	var t = dist * UTILS.speed_per_tile
	# 	level_ref.mouse_collider_store.save_delta(pos, dst)
	# 	level_ref.mouse_collider_store.push_step()
	# 	level_ref.mouse_collider_store.unchecked_move(pos, dst)
	# 	push_step()
	# 	pos = dst
	# 	UTILS.tween_move(self, UTILS.from_grid(dst), func(): pass, dist * UTILS.speed_per_tile)
	# 	return t
	level_ref.mouse_collider_store.save_delta(pos, dst)
	level_ref.mouse_collider_store.push_step()
	level_ref.mouse_collider_store.unchecked_move(pos, dst)
	push_step()
	var p = level_ref.mousegrass_collider_store.get_collider(pos)
	if p:
		p.mouse_in()
	pos = dst
	var n = level_ref.mousegrass_collider_store.get_collider(pos)
	if n:
		self.z_index = -1
		n.mouse_in()
	else:
		self.z_index = 0
	
	UTILS.tween_move(self, UTILS.from_grid(dst), func(): pass, UTILS.speed_per_tile)
	look_dir(dir)
	return UTILS.speed_per_tile

func look_dir(dir: Vector2):
	if dir.x == 0 and dir.y < 0:
		sprite.frame = 2
	if dir.x == 0 and dir.y > 0:
		sprite.frame = 0
	if dir.x < 0 and dir.y == 0:
		sprite.frame = 3
	if dir.x > 0 and dir.y == 0:
		sprite.frame = 1
	print("look_dir", dir, sprite.frame)
