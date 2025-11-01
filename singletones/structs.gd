extends Node


enum WorldState {
	Past,
	Future
}



class StateData:
	var data : Dictionary
	var ref : LevelstateReaction
	func revert():
		ref.restore_state(self)

class Level extends Node2D:
	var history = []
	var initial_state: Array[StateData] = []
	var step = 0
	var static_collider_store : StaticColliderStore
	var movable_collider_store : MovableColliderStore

	func _ready() -> void:
		history = []
		static_collider_store = StaticColliderStore.new()
		add_child(static_collider_store)
		movable_collider_store = MovableColliderStore.new()
		add_child(movable_collider_store)
		UTILS.log_print("[level] level ready")
		
		get_tree().call_group(LEVELSTATE_REACTION_GROUP, "_level_ready", self)
		get_tree().call_group(LEVELSTATE_REACTION_GROUP, "_post_level_ready")
	
	func reset():
		for s : StateData in initial_state:
			s.revert()
		history = []
		step = 0
	
	func take_snapshot():
		var h = history
		history = [[]]
		get_tree().call_group(LEVELSTATE_REACTION_GROUP, "push_step")
		var snapshot = take_history()
		history = h
		return snapshot

	func take_history():
		var h = history
		history = []
		step = 0
		return h

	func pop_from_history():
		if history.size() == 0:
			UTILS.log_print("[level] no prev step")
			return
		step -= 0
		return history.pop_back()

	func start_new_step():
		step += 1
		history.push_back([])
	
	func back():
		if history.size() == 0:
			UTILS.log_print("[level] no prev step")
			return
		UTILS.log_print("[level] back")
		var to_back = history.pop_back()
		for p : StateData in to_back:
			UTILS.log_prints("[level] reverting: ", p is StateData, p.ref.name, p.data)
			p.revert()
		step -= 1
	
	func push_initial(data: StateData):
		UTILS.log_print("[level] push initial state for " + str(data.ref.name) + " state: " + str(data.data))
		initial_state.push_back(data)
	
	func push_state(data: StateData):
		history[-1].push_back(data)


const LEVELSTATE_REACTION_GROUP : String = "levelstate_reaction"
class LevelstateReaction extends Node2D:
	var level_ref : Level
	func _init() -> void:
		self.add_to_group(LEVELSTATE_REACTION_GROUP)
	
	func _level_ready(level: Level, push_initial: bool = true):
		level_ref = level
		if push_initial: level_ref.push_initial(save_full_state())
		UTILS.log_print("[LevelstateReaction] level ready for " + self.name)
	
	func _post_level_ready():
		UTILS.log_print("[LevelstateReaction] post level ready for " + self.name)

	func save_full_state() -> StateData:
		return save_state()

	func save_state() -> StateData:
		var new_state = StateData.new()
		new_state.data = {}
		new_state.ref = self
		UTILS.log_print("[LevelstateReaction] save state for " + self.name + " state: " + str(new_state.data))
		return new_state 
	
	func restore_state(_old_state: StateData):
		UTILS.log_print("[LevelstateReaction] restore state for " + self.name)

	func push_step():
		var state = save_state()
		UTILS.log_print("[LevelstateReaction] push step for " + self.name + " state: " + str(state.data))
		level_ref.push_state(state)



const SWAP_REACTION_GROUP : String = "swap_reaction"
class SwapReaction extends LevelstateReaction:
	var is_future = false
	func _init() -> void:
		super._init()
		self.add_to_group(SWAP_REACTION_GROUP)
	
	func _level_ready(level: Level, push_initial: bool = true):
		is_future = GAMESTATE.worldstate == WorldState.Future
		super._level_ready(level, push_initial)

	func save_state() -> StateData:
		var s = super.save_state()
		s.data["is_future"] = is_future
		return s
	
	func restore_state(old_state: StateData):
		super.restore_state(old_state)
		is_future = old_state.data["is_future"]
	
	func on_swap(world_state: WorldState):
		is_future = world_state == WorldState.Future


const STATE_COLLIDER_PLAYER_MASK : int = 1
const STATE_COLLIDER_MOVABLE_MASK : int = 2
const STATE_COLLIDER_WALL_MASK : int = 4

const STATE_COLLIDER_GROUP : String = "state_collider"
class StateCollider extends SwapReaction:
	var mask : int
	var pos : Vector2i
	func _init(set_mask: int = 1) -> void:
		super._init()
		self.mask = set_mask
		self.add_to_group(STATE_COLLIDER_GROUP)
	
	func _level_ready(level: Level, push_initial: bool = true):
		super._level_ready(level, push_initial)
		pos = UTILS.to_grid(global_position)
		add_collider_to_store()
	
	func add_collider_to_store():
		level_ref.static_collider_store.add_collider(self)

	func save_full_state() -> StateData:
		var s = super.save_state()
		s.data["pos"] = pos
		return s
	
	func save_state() -> StateData:
		var s = super.save_state()
		return s
	
	func restore_state(old_state: StateData):
		super.restore_state(old_state)
		var p = old_state.data.get("pos")
		if p:
			pos = p

	func is_occupied(check_mask: int) -> bool:
		UTILS.log_prints("[StateCollider] is_occupied", check_mask, mask)
		return check_mask & mask != 0

const MOVABLE_COLLIDER_GROUP : String = "movable_collider"
class MovableCollider extends StateCollider:
	func _init(set_mask: int = 1) -> void:
		super._init(set_mask)
		self.add_to_group(MOVABLE_COLLIDER_GROUP)
	
	func _level_ready(level: Level, push_initial: bool = true):
		super._level_ready(level, push_initial)
	
	func add_collider_to_store():
		level_ref.movable_collider_store.add_collider(self)
	
	func save_state() -> StateData:
		var s = super.save_state()
		s.data["pos"] = pos
		return s
	
	func restore_state(old_state: StateData):
		super.restore_state(old_state)
		var p = old_state.data.get("pos")
		if p:
			pos = p
			global_position = UTILS.from_grid(pos)

	func is_occupied(check_mask: int) -> bool:
		UTILS.log_prints("[MovableCollider] is_occupied", check_mask, mask, check_mask & mask)
		return check_mask & mask != 0



class Moved:
	var from : Vector2i
	var to : Vector2i


class StaticColliderStore extends LevelstateReaction:
	var pos_to_collider : Dictionary = {}
	var collider_to_pos : Dictionary = {}

	func save_full_state() -> StateData:
		var s = super.save_state()
		s.data["pos_to_collider"] = pos_to_collider.duplicate(true)
		s.data["collider_to_pos"] = collider_to_pos.duplicate(true)
		return s

	func _level_ready(level: Level, push_initial: bool = false):
		super._level_ready(level, push_initial)
	
	func _post_level_ready():
		super._post_level_ready()
		var s = save_full_state()
		UTILS.log_print("[static_collider_store] push initial for " + self.name + " state: " + str(s.data))
		level_ref.push_initial(s)
	
	func _init() -> void:
		super._init()
		pos_to_collider = {}
		collider_to_pos = {}

	func add_collider(ref : LevelstateReaction):
		var pos = UTILS.to_grid(ref.global_position)
		pos_to_collider[pos] = ref
		collider_to_pos[ref] = pos
	
	func get_collider(p: Vector2i):
		return pos_to_collider.get(p)

	func collide(p: Vector2i, mask: int) -> bool:
		UTILS.log_prints("[static_collider_store] collide", p, get_collider(p), mask)
		return get_collider(p) != null and get_collider(p).is_occupied(mask)

class MovableColliderStore extends StaticColliderStore:
	var moved : Array[Moved] = []

	func _init() -> void:
		super._init()
		moved = []

	func save_state() -> StateData:
		var s = super.save_state()
		s.data["moved"] = moved
		moved = []
		return s
	
	func can_push(obj: MovableCollider, dir: Vector2i, mask: int):
		var from = obj.pos
		var to = from + dir
		return obj.is_occupied(mask) && !level_ref.movable_collider_store.collide(to, mask)
	
	func save_delta(from: Vector2i, to: Vector2i):
		var m = Moved.new()
		m.from = from
		m.to = to
		moved.append(m)

	func unchecked_push_object(obj: MovableCollider, dir: Vector2i):
		var from = obj.pos
		var to = from + dir
		obj.pos = to
		return true

	func restore_state(old_state: StateData):
		super.restore_state(old_state)
		var p = old_state.data.get("pos_to_collider")
		if p:
			pos_to_collider = p.duplicate(true)
		var c = old_state.data.get("collider_to_pos")
		if c:
			collider_to_pos = c.duplicate(true)
		var old_moved = old_state.data.get("moved")
		if old_moved:
			for m in old_moved:
				unchecked_move(m.to, m.from)
		moved = []
	
	func unchecked_move(from: Vector2i, to: Vector2i):
		var c = pos_to_collider[from]
		pos_to_collider.erase(from)
		pos_to_collider[to] = c
		collider_to_pos.erase(c)
		collider_to_pos[c] = to
	

	
