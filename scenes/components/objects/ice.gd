extends STRUCTS.MovableCollider

@onready var sprite = $Sprite2D

func _init() -> void:
	super._init(STATE_COLLIDER_PLAYER_MASK | STATE_COLLIDER_MOVABLE_MASK)

func _level_ready(level: Level, push_initial: bool = true):
	pos = UTILS.to_grid(position)
	position = UTILS.from_grid(pos)
	super._level_ready(level, push_initial)
	process_swap(is_future)

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
	pos = old_state.data["pos"]
	position = UTILS.from_grid(pos)
	process_swap(is_future)

func process_swap(world_state: WorldState):
	if world_state == STRUCTS.WorldState.Future:
		mask = 0
		sprite.region_rect.position.x = 16
	else:
		sprite.region_rect.position.x = 0
		mask = STATE_COLLIDER_PLAYER_MASK
