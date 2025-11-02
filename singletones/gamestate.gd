extends STRUCTS.LevelstateReaction


var worldstate = STRUCTS.WorldState.Future
var player
var camera

func swap():
	push_step()
	var new_state = UTILS.reverse_state(worldstate)
	print("[gamestate] swap to", new_state)
	get_tree().call_group(STRUCTS.SWAP_REACTION_GROUP, "on_swap", new_state)
	worldstate = new_state

func save_state() -> STRUCTS.StateData:
	var s = STRUCTS.StateData.new()
	s.data = {"worldstate" : GAMESTATE.worldstate}
	s.ref = self
	return s

func restore_state(old_state: STRUCTS.StateData):
	super.restore_state(old_state)
	print("[level instance] restore state")
	worldstate = old_state.data["worldstate"]

var static_colliders : Dictionary = {}
var swap_colliders : Dictionary = {}
var movable_colliders : Dictionary = {}


func get_collider(p: Vector2i):
	var c = static_colliders.get(p)
	if c: return c
	c = movable_colliders.get(p)
	if c: return c
	c = swap_colliders.get(p)
	if c: return c
	return null


func get_static_collider(p: Vector2i):
	return static_colliders.get(p)

func pop_static_collider(p: Vector2i):
	var value = static_colliders.get(p)
	if !value: return null
	static_colliders.erase(p)
	return value

func set_static_collider(node: Node, p: Vector2i):
	static_colliders[p] = node

func get_movable_collider(p: Vector2i):
	return movable_colliders.get(p)

func pop_movable_collider(p: Vector2i):
	var value = movable_colliders.get(p)
	if !value: return null
	movable_colliders.erase(p)
	return value

func set_movable_collider(node: Node, p: Vector2i):
	movable_colliders[p] = node

func get_swap_collider(p: Vector2i):
	return swap_colliders.get(p)

func pop_swap_collider(p: Vector2i):
	var value = swap_colliders.get(p)
	if !value: return null
	swap_colliders.erase(p)
	return value

func set_swap_collider(node: Node, p: Vector2i):
	swap_colliders[p] = node
