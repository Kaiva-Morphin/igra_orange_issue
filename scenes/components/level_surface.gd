extends STRUCTS.SwapReaction

@onready var past_root : Node2D = $Past
@onready var future_root : Node2D = $Future

var offset = Vector2i(0, -13)
func _level_ready(level: Level, push_initial: bool = true):
	var pos = UTILS.to_grid(global_position)
	global_position = Vector2(UTILS.from_grid(pos)) - Vector2(UTILS.tile_size) * 0.5
	var pasts = past_root.get_children()
	var futures = future_root.get_children()
	for i in range(pasts.size()):
		var past = pasts[i]
		var future = futures[i]
		var tiles = past.get_used_cells()
		for tile_pos in tiles:
			var ac : Vector2i = past.get_cell_atlas_coords(tile_pos)
			var d : TileData = past.get_cell_tile_data(tile_pos)
			if d == null:
				continue
			var source_id = past.get_cell_source_id(tile_pos)
			future.set_cell(tile_pos, source_id, ac + offset)
			var is_ground = d.get_custom_data("ground")
			if is_ground:
				var g = STRUCTS.Ground.new()
				g.global_position = future.to_global(UTILS.from_grid(tile_pos + Vector2i.ONE)) - self.global_position
				add_child(g)
				g._level_ready(level, push_initial)
			var collide_in_future = d.get_custom_data("collide_in_future")
			if collide_in_future:
				var g = STRUCTS.CollideInFuture.new()
				g.global_position = future.to_global(UTILS.from_grid(tile_pos + Vector2i.ONE)) - self.global_position
				add_child(g)
				g._level_ready(level, push_initial)
			var collide_in_past = d.get_custom_data("collide_in_past")
			if collide_in_past:
				var g = STRUCTS.CollideInPast.new()
				g.global_position = past.to_global(UTILS.from_grid(tile_pos + Vector2i.ONE)) - self.global_position
				add_child(g)
				g._level_ready(level, push_initial)
			var is_ice = d.get_custom_data("ice")
			if is_ice:
				var g = STRUCTS.IceCollider.new()
				g.global_position = past.to_global(UTILS.from_grid(tile_pos + Vector2i.ONE)) - self.global_position
				add_child(g)
				g._level_ready(level, push_initial)
		super._level_ready(level, push_initial)
		process_state(is_future)

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
		past_root.hide()
		future_root.show()
	else:
		past_root.show()
		future_root.hide()
