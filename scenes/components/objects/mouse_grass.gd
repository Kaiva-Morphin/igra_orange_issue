extends STRUCTS.StateCollider

@onready var sprite = $Sprite2D
@onready var reflection = $Sprite2D2

func _init() -> void:
	super._init(STATE_COLLIDER_PLAYER_MASK | STATE_COLLIDER_MOVABLE_MASK)


func _level_ready(level: Level, push_initial: bool = true):
	pos = UTILS.to_grid(global_position)
	global_position = UTILS.from_grid(pos)
	super._level_ready(level, push_initial)
	process_swap(GAMESTATE.worldstate)

func add_collider_to_store():
	level_ref.static_collider_store.add_collider(self)
	level_ref.mousegrass_collider_store.add_collider(self)

func on_swap(world_state: WorldState, push_step_needed : bool = true):
	if push_step_needed: push_step()
	super.on_swap(world_state, push_step_needed)
	UTILS.log_print("[mousegrass] on_swap " + str(world_state))
	process_swap(world_state)

func save_state() -> StateData:
	var s = super.save_state()
	s.data["frame"] = sprite.frame
	return s

func restore_state(old_state: StateData):
	super.restore_state(old_state)
	sprite.frame = old_state.data["frame"]
	process_swap(GAMESTATE.worldstate)

func get_mask(_world: WorldState) -> int:
	var mc = level_ref.mouse_collider_store.get_collider(pos)
	if _world == STRUCTS.WorldState.Future and !mc:
		return STATE_COLLIDER_PLAYER_MASK
	elif mc: # && mc.get_mask(UTILS.reverse_state(_world)) != 0:
		return 0
	else:
		return STATE_COLLIDER_PLAYER_MASK | STATE_COLLIDER_MOVABLE_MASK

func process_swap(world_state: WorldState):
	mask = get_mask(world_state)
	if world_state == STRUCTS.WorldState.Future:
		var h = false
		# var mc = level_ref.mouse_collider_store.get_collider(pos)
		# if mc:
		# 	h = true
		if h:
			reflection.frame = 1
			sprite.frame = 1
		else:
			reflection.frame = 0
			sprite.frame = 0
	else:
		if mask == 0:
			reflection.frame = 3
			sprite.frame = 3
		else:
			reflection.frame = 2
			sprite.frame = 2

func mouse_in():
	process_swap(GAMESTATE.worldstate)
