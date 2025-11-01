extends STRUCTS.SwapReaction

var pos : Vector2i
@onready var sprite : Sprite2D = $Sprite2D

func _level_ready(level: Level, push_initial: bool = true):
	print("[player] level ready for " + self.name)
	pos = UTILS.to_grid(position)
	position = UTILS.from_grid(pos)
	super._level_ready(level, push_initial)

func restore_state(old_state: StateData):
	super.restore_state(old_state)
	print("[player] restore state")
	pos = old_state.data["pos"]
	sprite.frame = old_state.data.get("frame")
	UTILS.log_prints("[player] State restored " + str(pos) + " " + str(sprite.region_rect))
	position = UTILS.from_grid(pos)

func save_state() -> StateData:
	var s = super.save_state()
	pos = UTILS.to_grid(position)
	s.data["pos"] = pos
	s.data["frame"] = sprite.frame
	print("[player] save state for " + self.name + " state: " + str(s.data))
	return s

func push_step():
	super.push_step()

@onready var anim : AnimationPlayer = $AnimationPlayer

func play(n: String, time: float = 0.8):
	anim.play("walk_" + n, -1, time)

func stop_anim():
	anim.stop(true)

func play_right(time: float = 0.8):
	anim.play("walk_right", -1, time)
func play_up(time: float = 0.8):
	anim.play("walk_up", -1, time)
func play_left(time: float = 0.8):
	anim.play("walk_left", -1, time)
func play_down(time: float = 0.8):
	anim.play("walk_down", -1, time)
# func swap():
# 	GAMESTATE.swap()
# 	processing_step = false

# func _process(_dt: float) -> void:
# 	if processing_step:
# 		return
	
# 	if Input.is_action_just_pressed("swap"):
# 		processing_step = true
# 		level_ref.start_new_step()
# 		swap()
# 		return
	
# 	var i_dir = UTILS.get_input_dir()
# 	if i_dir == Vector2i.ZERO:
# 		return
# 	var dst = position + Vector2(i_dir * UTILS.tile_size)
# 	processing_step = true
# 	level_ref.start_new_step()
# 	tween_move(self, dst, func(): processing_step = false)

# 	# var pp = Vector2i(player.position)
	# var dir = UTILS.tile_size * i_dir
	# var m_pos_grid = UTILS.to_grid(pp + dir)
	# var m = GAMESTATE.get_movable_collider(m_pos_grid)
	# if m and m.is_movable():
	#     var m_target = pp + dir * 2
	#     var m_target_grid = UTILS.to_grid(m_target)
	#     var c = GAMESTATE.get_collider(m_target_grid)
	#     if (c and c.is_swap_collider_now()) or is_wall(m_target_grid):
	#         print("swap_collider blocked by wall or another collider")
	#         return
	#     m = GAMESTATE.pop_movable_collider(m_pos_grid)
	#     GAMESTATE.set_movable_collider(m, m_target_grid)
	#     tween_move(m, m_target)
	# var s = GAMESTATE.get_swap_collider(m_pos_grid)
	# if s and s.is_swap_collider_now():
	#     return
	# var dst = pp + dir
	# var cell = future.local_to_map(dst)
	# var tile : TileData = future.get_cell_tile_data(cell)
	# print("Moving")
	# if tile and tile.get_collision_polygons_count(0):
	#     print("Blocked by wall")
	#     return
	# in_move = true
	# tween_move(player, dst, func(): in_move = false)
