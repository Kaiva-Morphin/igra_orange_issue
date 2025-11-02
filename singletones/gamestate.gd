extends STRUCTS.LevelstateReaction


var worldstate = STRUCTS.WorldState.Past
var player
var camera
var level_controller : STRUCTS.Level

func swap():
	push_step()
	var new_state = UTILS.reverse_state(worldstate)
	print("[gamestate] swap to", new_state)
	get_tree().call_group(STRUCTS.SWAP_REACTION_GROUP, "on_swap", new_state)
	worldstate = new_state

func save_state() -> STRUCTS.StateData:
	var s = STRUCTS.StateData.new()
	s.data = {"worldstate" : GAMESTATE.worldstate}
	print("[level instance] save state", s.data)
	s.ref = self
	return s

func restore_state(old_state: STRUCTS.StateData):
	super.restore_state(old_state)
	print("[level instance] restore state", old_state.data)
	worldstate = old_state.data["worldstate"]
	# get_tree().call_group(STRUCTS.SWAP_REACTION_GROUP, "on_swap", worldstate)
