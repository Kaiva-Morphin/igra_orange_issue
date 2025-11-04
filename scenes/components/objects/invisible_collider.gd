extends STRUCTS.StateCollider

@export var collide_player_in_future : bool = false
@export var collide_movable_in_future : bool = false
@export var collide_player_in_past : bool = false
@export var collide_movable_in_past : bool = false

func _init() -> void:
	super._init(get_mask(GAMESTATE.worldstate))

func _ready() -> void:
	$Sprite2D.hide()

func _level_ready(level: Level, push_initial: bool = true):
	pos = UTILS.to_grid(global_position)
	global_position = Vector2(UTILS.from_grid(pos)) # - Vector2(UTILS.tile_size * 0.5)
	super._level_ready(level, push_initial)
	process_swap(GAMESTATE.worldstate)

func on_swap(world_state: WorldState, push_step_needed : bool = true):
	if push_step_needed:
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
	var m = 0
	if _world == STRUCTS.WorldState.Past:
		if collide_movable_in_past:
			m |= STATE_COLLIDER_MOVABLE_MASK
		if collide_player_in_past:
			m |= STATE_COLLIDER_PLAYER_MASK
	else:
		if collide_movable_in_future:
			m |= STATE_COLLIDER_MOVABLE_MASK
		if collide_player_in_future:
			m |= STATE_COLLIDER_PLAYER_MASK
	return m

func process_swap(world_state: WorldState):
	mask = get_mask(world_state)
