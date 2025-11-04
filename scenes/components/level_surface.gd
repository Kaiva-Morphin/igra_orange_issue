extends STRUCTS.SwapReaction

@onready var past_from_future : Node2D = $AutoPast
@onready var future_to_past : Node2D = $FutureDraw

@onready var future_from_past : Node2D = $Future
@onready var past_to_future : Node2D = $Past

var offset = Vector2i(0, -13)
func _level_ready(level: Level, push_initial: bool = true):
	var pos = UTILS.to_grid(global_position)
	global_position = Vector2(UTILS.from_grid(pos)) - Vector2(UTILS.tile_size) * 0.5
	gen(future_to_past, past_from_future, level, push_initial, true)
	gen(past_to_future, future_from_past, level, push_initial, false)
	super._level_ready(level, push_initial)
	process_state(GAMESTATE.worldstate)

func gen(from, to, level, push_initial, rev):
	# if from == null or to == null:
	# 	return
	var pasts = from.get_children()
	var futures = to.get_children()
	for i in range(pasts.size()):
		var past : TileMapLayer = pasts[i]
		var future = futures[i]
		var tiles = past.get_used_cells()

		for tile_pos in tiles:
			var ac : Vector2i = past.get_cell_atlas_coords(tile_pos)
			var d : TileData = past.get_cell_tile_data(tile_pos)

			if d == null:
				continue
			var source_id = past.get_cell_source_id(tile_pos)
			var o = offset
			if rev:
				o *= -1
			var af = ac + o
			var ts : TileSet = past.tile_set
			var source = ts.get_source(0)
			var df : TileData = source.get_tile_data(af, 0)
			
			future.set_cell(tile_pos, source_id, af)

			var is_ground = d.get_custom_data("ground") || (df && df.get_custom_data("ground"))
			if is_ground:
				var g = STRUCTS.Ground.new()
				g.global_position = future.to_global(UTILS.from_grid(tile_pos + Vector2i.ONE)) - self.global_position
				add_child(g)
				g._level_ready(level, push_initial)
			var collide_in_future = d.get_custom_data("collide_in_future") || (df && df.get_custom_data("collide_in_future"))
			if collide_in_future:
				var g = STRUCTS.CollideInFuture.new()
				g.global_position = future.to_global(UTILS.from_grid(tile_pos + Vector2i.ONE)) - self.global_position
				add_child(g)
				g._level_ready(level, push_initial)
			var collide_in_past = d.get_custom_data("collide_in_past") || (df && df.get_custom_data("collide_in_past"))
			if collide_in_past:
				var g = STRUCTS.CollideInPast.new()
				g.global_position = past.to_global(UTILS.from_grid(tile_pos + Vector2i.ONE)) - self.global_position
				add_child(g)
				g._level_ready(level, push_initial)
			var is_ice = d.get_custom_data("ice") || (df && df.get_custom_data("ice"))
			if is_ice:
				var g = STRUCTS.IceCollider.new()
				g.global_position = past.to_global(UTILS.from_grid(tile_pos + Vector2i.ONE)) - self.global_position
				add_child(g)
				g._level_ready(level, push_initial)
		



func save_state() -> StateData:
	var s = super.save_state()
	# print("[level_surface] save state for " + self.name + " state: " + str(s.data))
	return s

func restore_state(old_state: STRUCTS.StateData):
	super.restore_state(old_state)
	# print("[level_surface] old " + str(old_state.data) + " state: " + str(is_future))
	process_state(GAMESTATE.worldstate)

func on_swap(world_state: WorldState, push_step_needed : bool = true):
	if push_step_needed: push_step()
	# prints("[level_surface] on_swap", world_state)
	super.on_swap(world_state)
	process_state(world_state)


func process_state(world_state: WorldState):
	if world_state:
		past_from_future.hide()
		past_to_future.hide()
		future_from_past.show()
		future_to_past.show()
	else:
		past_from_future.show()
		past_to_future.show()
		future_from_past.hide()
		future_to_past.hide()
