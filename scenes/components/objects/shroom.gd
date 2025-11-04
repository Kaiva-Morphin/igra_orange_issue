extends STRUCTS.StateCollider

@onready var sprite = $Sprite2D
@onready var reflection = $Sprite2D2
@onready var in_past_sprite = $Sprite2D3

func _init() -> void:
	super._init(0)

func _level_ready(level: Level, push_initial: bool = true):
	pos = UTILS.to_grid(global_position)
	global_position = UTILS.from_grid(pos)
	super._level_ready(level, push_initial)
	process_swap(GAMESTATE.worldstate)

func on_swap(world_state: WorldState, push_step_needed : bool = true):
	if push_step_needed: push_step()
	super.on_swap(world_state, push_step_needed)
	UTILS.log_print("[ice] on_swap " + str(world_state))
	process_swap(world_state)

func save_state() -> StateData:
	var s = super.save_state()
	return s

func restore_state(old_state: StateData):
	super.restore_state(old_state)
	process_swap(GAMESTATE.worldstate)

func get_mask(_world: WorldState) -> int:
	print("[shroom] get_mask " + str(_world))
	var mc = level_ref.movable_collider_store.get_collider(pos)
	if _world == STRUCTS.WorldState.Past:
		return 2
	elif mc && mc.get_mask(UTILS.reverse_state(_world)) != 0:
		return 0
	else:
		return 3

func process_swap(world_state: WorldState):
	mask = get_mask(world_state)
	if world_state == STRUCTS.WorldState.Future:
		var h = false
		var mc = level_ref.movable_collider_store.get_collider(pos)
		if mc:
			var m = mc.get_mask(GAMESTATE.worldstate) # idk why
			if m != 0:
				h = true
		if h:
			reflection.frame = 1
			sprite.frame = 1
		else:
			reflection.frame = 2
			sprite.frame = 2
		in_past_sprite.hide()
		sprite.show()
		reflection.show()

	else:
		in_past_sprite.hide()
		sprite.show()
		reflection.show()
		reflection.frame = 0
		sprite.frame = 0
