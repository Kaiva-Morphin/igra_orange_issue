extends STRUCTS.SwapReaction

func _level_ready(level: Level, push_initial: bool = true):
	super._level_ready(level, push_initial)

func save_state() -> StateData:
	var s = super.save_state()
	print("[level_surface] save state for " + self.name + " state: " + str(s.data))
	return s

func restore_state(old_state: STRUCTS.StateData):
	super.restore_state(old_state)
	# print("[level_surface] old " + str(old_state.data) + " state: " + str(is_future))
	process_state(is_future)

func on_swap(world_state: WorldState):
	push_step()
	prints("[level_surface] on_swap", world_state)
	super.on_swap(world_state)
	process_state(world_state)

func process_state(world_state: WorldState):
	if world_state:
		$Future.show()
		$Past.hide()
	else:
		$Future.hide()
		$Past.show()
