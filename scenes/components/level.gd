extends STRUCTS.Level

var processing_step = false
var requested_swap = false

@onready var player = $Player

func _ready() -> void:
	super._ready()

var processing_history = []
var processing_revert_stepping = false
var processing_revert_step = 0

func smooth_back(item: StateData, on_end = null, speed_per_tile = UTILS.speed_per_tile) -> bool:
	var pos = item.data.get("pos")
	if pos != null:
		var p = item.ref.position
		item.revert()
		item.ref.position = p
		var dist = Vector2(UTILS.to_grid(item.ref.position) - pos).length()
		UTILS.tween_move(item.ref, pos * UTILS.tile_size, on_end, speed_per_tile * dist)
		return true
	else:
		item.revert()
		return false


func step_relative_speed(s: int) -> float:
	return max(0.1 / pow(1.05, s), 0.02)

var swap_speed = UTILS.speed_per_tile * 16
func process_revert() -> bool:
	if processing_revert_stepping:
		return true
	var snapshot = processing_history.pop_front()
	if snapshot:
		for item in snapshot:
			processing_revert_stepping = smooth_back(item, func(): processing_revert_stepping = false, step_relative_speed(processing_revert_step))
		processing_revert_step += 1
		if !processing_revert_stepping:
			processing_revert_stepping = true
			get_tree().create_timer(step_relative_speed(processing_revert_step) * swap_speed).connect("timeout", func(): processing_revert_stepping = false)
	return processing_history.size() != 0 or processing_revert_stepping

var dbg = []
func spawn_dbg(p: Vector2, color: Color):
	var d : Sprite2D = $DBG.duplicate()
	add_child(d)
	d.position = p
	d.modulate = color
	d.show()
	dbg.append(d)


func _process(_dt: float) -> void:
	# for v in dbg:
	# 	v.queue_free()
	# dbg = []
	# if true:
	# 	spawn_dbg(UTILS.from_grid(player.pos) , Color(0, 1, 0))
	# for i in movable_collider_store.pos_to_collider.values():
	# 	spawn_dbg(UTILS.from_grid(i.pos), Color(1, 0, 0))
	# for i in movable_collider_store.pos_to_collider.keys():
	# 	spawn_dbg(Vector2(UTILS.from_grid(i)) + Vector2(8, 8), Color(1, 0, 1))
	# for i in static_collider_store.pos_to_collider.values():
	# 	spawn_dbg(UTILS.from_grid(i.pos), Color(1, 1, 0))
	# for i in static_collider_store.pos_to_collider.keys():
	# 	spawn_dbg(Vector2(UTILS.from_grid(i)) + Vector2(8, 8), Color(1, 1, 1))


	if process_revert():
		return
	
	if Input.is_action_just_pressed("swap"):
		requested_swap = true
	
	if processing_step:
		return
	else:
		player.stop_anim()
	
	if requested_swap:
		requested_swap = false

		start_new_step()
		UTILS.log_print("[level instance] swap")
		GAMESTATE.swap()
	
	if Input.is_action_just_pressed("step_back"):
		UTILS.log_prints("[level instance] step_back")
		var h = pop_from_history()
		if h:
			for item in h:
				if smooth_back(item, func(): processing_step = false):
					processing_step = true
		return
	
	if Input.is_action_just_pressed("hard_reset"):
		UTILS.log_print("[level instance] hard reset")
		reset()
		return
	
	if Input.is_action_just_pressed("reset"):
		UTILS.log_print("[level instance] reset")
		var hist = take_history()
		hist.reverse()
		processing_history = hist
		processing_revert_step = 0
		return
	
	var i_dir = UTILS.get_input_dir()
	if i_dir == Vector2i.ZERO:
		return
	var grid_pos = player.pos;
	if static_collider_store.is_occupied_for(grid_pos + i_dir, STATE_COLLIDER_PLAYER_MASK):
		return
	
	var m = movable_collider_store.get_collider(grid_pos + i_dir)
	if m && m.is_occupied_for(STATE_COLLIDER_PLAYER_MASK):
		UTILS.log_prints("[level instance] push", grid_pos + i_dir, "real", m.pos)
		if !movable_collider_store.can_push(m, i_dir, STATE_COLLIDER_PLAYER_MASK):
			UTILS.log_print("[level instance] push blocked")
			return
		start_new_step()
		
		movable_collider_store.save_delta(m.pos, m.pos + i_dir)
		movable_collider_store.push_step()

		movable_collider_store.unchecked_move(m.pos, m.pos + i_dir)

		m.push_step()
		movable_collider_store.unchecked_push_object(m, i_dir)

		UTILS.log_prints("[level instance] move", m.pos)
		UTILS.tween_move(m, UTILS.from_grid(grid_pos) + i_dir * 2 * UTILS.tile_size, func(): processing_step = false)
		# processing_step = true
		# return
	else:
		start_new_step()




	var anim_name = UTILS.dir_to_anim(i_dir)
	if anim_name:
		player.play(anim_name, 4)
	
	var dst = player.position + Vector2(i_dir * UTILS.tile_size)
	processing_step = true
	player.push_step()
	player.pos = player.pos + i_dir
	UTILS.tween_move(player, dst, func(): processing_step = false)
