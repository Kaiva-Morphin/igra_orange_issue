extends STRUCTS.StateCollider

@onready var sprite = $Sprite2D
@onready var reflection = $Sprite2D2
@onready var in_future_sprite = $Sprite2D3

func _init() -> void:
	super._init(STATE_COLLIDER_PLAYER_MASK | STATE_COLLIDER_MOVABLE_MASK)

func _level_ready(level: Level, push_initial: bool = true):
	pos = UTILS.to_grid(global_position)
	global_position = UTILS.from_grid(pos)
	super._level_ready(level, push_initial)
	process_swap(GAMESTATE.worldstate)

func on_swap(world_state: WorldState):
	push_step()
	super.on_swap(world_state)
	UTILS.log_print("[ice] on_swap " + str(world_state))
	process_swap(world_state)

func save_state() -> StateData:
	var s = super.save_state()
	return s

func restore_state(old_state: StateData):
	super.restore_state(old_state)
	process_swap(GAMESTATE.worldstate)

func get_mask(_world: WorldState) -> int:
	if _world == STRUCTS.WorldState.Future:
		return 0
	else:
		return STATE_COLLIDER_PLAYER_MASK | STATE_COLLIDER_MOVABLE_MASK

func process_swap(world_state: WorldState):
	mask = get_mask(world_state)
	if world_state == STRUCTS.WorldState.Future:
		# var h = false
		# var mc = level_ref.movable_collider_store.get_collider(pos)
		# if mc:
		# 	var m = mc.get_mask(GAMESTATE.worldstate)
		# 	UTILS.log_print("[ice] movable mask " + str(m))
		# 	if m != 0:
		# 		h = true
		# var sc = level_ref.static_collider_store.get_collider(pos)
		# if sc:
		# 	var m = sc.get_mask(GAMESTATE.worldstate)
		# 	UTILS.log_print("[ice] static mask " + str(m))
		# 	if m != 0:
		# 		UTILS.log_print("[ice] swap blocked")
		# 		h = true
		# if h:
		# 	in_future_sprite.hide()
		# else:
		in_future_sprite.show()
		sprite.hide()
		reflection.hide()
	else:
		in_future_sprite.hide()
		sprite.show()
		reflection.show()
