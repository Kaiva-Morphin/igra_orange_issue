extends STRUCTS.LevelstateReaction


var worldstate = STRUCTS.WorldState.Past
var player
var camera
var level_controller : STRUCTS.Level
var vignette
var canvas

var touch_enabled = false
var touch_inited = false

var touch_meow_just_pressed := false
var touch_swap_just_pressed := false
var touch_back_just_pressed := false
var touch_rewind_just_pressed := false
var touch_fastrewind_just_pressed := false


func swap():
	push_step()
	var new_state = UTILS.reverse_state(worldstate)
	print("[gamestate] swap to", new_state)
	get_tree().call_group(STRUCTS.SWAP_REACTION_GROUP, "on_swap", new_state, true)
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

	get_tree().call_group(STRUCTS.SWAP_REACTION_GROUP, "on_swap", worldstate, false)

func acquire_power():
	level_controller.powers_unlocked = true
	canvas.on_powers_unlocked()
