extends STRUCTS.Level

var processing_step = false
var requested_swap = false

@export var dbg_render : bool = false

var player
var tweened_player_pos 

@onready var swap_interpolation : TextureRect = $Canvas/PrevSwapState

func _ready() -> void:
	super._ready()
	GAMESTATE.camera = get_tree().get_nodes_in_group("camera")[0]
	GAMESTATE.player = get_tree().get_nodes_in_group("player")[0]
	player = GAMESTATE.player
	tweened_player_pos = player.global_position
	CAMERA.on_ready()

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

var screenshot: Texture2D

func _process(_dt: float) -> void:
	CAMERA.update(_dt)
	for v in dbg:
		v.queue_free()
	dbg = []
	if dbg_render:
		if true:
			spawn_dbg(UTILS.from_grid(player.pos) , Color(0, 1, 0))
		for i in movable_collider_store.pos_to_collider.values():
			spawn_dbg(UTILS.from_grid(i.pos), Color(1, 0, 0))
		for i in movable_collider_store.pos_to_collider.keys():
			spawn_dbg(Vector2(UTILS.from_grid(i)) + Vector2(8, 8), Color(1, 0, 1))
		for i in static_collider_store.pos_to_collider.values():
			spawn_dbg(UTILS.from_grid(i.pos), Color(1, 1, 0))
		for i in static_collider_store.pos_to_collider.keys():
			spawn_dbg(Vector2(UTILS.from_grid(i)) + Vector2(8, 8), Color(1, 1, 1))

	if process_revert():
		return

	if Input.is_action_just_pressed("swap"):
		requested_swap = true
	
	if processing_step:
		return
	else:
		player.stop_anim()

	if requested_swap:
		await RenderingServer.frame_post_draw
		var viewport_texture = get_viewport().get_texture()
		var img = viewport_texture.get_image()
		var tex = ImageTexture.create_from_image(img)
		requested_swap = false
		swap_interpolation.texture = tex
		processing_step = true
		var mat : ShaderMaterial = swap_interpolation.material
		mat.set_shader_parameter("radius", 0.0)
		var tween = create_tween()
		tween.tween_property(
			mat,
			"shader_parameter/radius",
			1.0,
			1.2
		)
		tween.finished.connect(func(): processing_step = false)

		var suppressed = false
		var mc = movable_collider_store.get_collider(player.pos)
		if mc:
			var mask = mc.get_mask(UTILS.reverse_state(GAMESTATE.worldstate))
			if mask & STATE_COLLIDER_PLAYER_MASK != 0:
				UTILS.log_print("[level instance] swap blocked")
				suppressed = true
		var sc = static_collider_store.get_collider(player.pos)
		if sc:
			var mask = sc.get_mask(UTILS.reverse_state(GAMESTATE.worldstate))
			if mask & STATE_COLLIDER_PLAYER_MASK != 0:
				UTILS.log_print("[level instance] swap blocked")
				suppressed = true
		start_new_step()
		player.push_step()
		player.suppressed = suppressed
		UTILS.log_print("[level instance] swap")
		GAMESTATE.swap()
		return
	if Input.is_action_just_pressed("step_back"):
		UTILS.log_prints("[level instance] step_back")
		var h = pop_from_history()
		if h:
			for item in h:
				if smooth_back(item, func(): processing_step = false):
					processing_step = true
		return
	
	if player.suppressed:
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
	var dst_grid = grid_pos + i_dir
	if static_collider_store.is_occupied_for(dst_grid, STATE_COLLIDER_PLAYER_MASK):
		return
	
	var m = movable_collider_store.get_collider(dst_grid)
	var i = ice_store.get_collider(dst_grid)
	if m && m.is_occupied_for(STATE_COLLIDER_PLAYER_MASK):
		if !movable_collider_store.can_push(m, i_dir, STATE_COLLIDER_PLAYER_MASK):
			UTILS.log_print("[level instance] push blocked")
			return
		start_new_step()
		var m_dst = m.pos + i_dir
		
		if i and GAMESTATE.worldstate == WorldState.Past:
			m_dst = get_slide_end(m_dst, i_dir)
			var d = m_dst - grid_pos
			var dist = max(abs(d.x), abs(d.y))
			var t = UTILS.speed_per_tile * dist
			movable_collider_store.save_delta(m.pos, m_dst)
			movable_collider_store.push_step()
			movable_collider_store.unchecked_move(m.pos, m_dst)
			m.push_step()
			movable_collider_store.unchecked_push_object(m, i_dir)
			m.pos = m_dst
			processing_step = true
			UTILS.tween_move(m, UTILS.from_grid(m_dst), func(): processing_step = false, t)
			return

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

	var dst = player.position + Vector2(i_dir * UTILS.tile_size)

	if i and GAMESTATE.worldstate == WorldState.Past:
		var end = get_slide_end(grid_pos, i_dir)
		var d = end - grid_pos
		var dist = max(abs(d.x), abs(d.y))
		player.push_step()
		player.pos = end
		var anim_n = UTILS.dir_to_anim(i_dir)
		if anim_n:
			player.play(anim_n, 4)
		UTILS.tween_move(player, UTILS.from_grid(end), func(): processing_step = false, dist * UTILS.speed_per_tile)
		processing_step = true
		return

	var anim_name = UTILS.dir_to_anim(i_dir)
	if anim_name:
		player.play(anim_name, 4)
	processing_step = true
	player.push_step()
	player.pos = player.pos + i_dir
	UTILS.tween_move(player, dst, func(): processing_step = false)


func get_slide_end(from : Vector2i, dir : Vector2i) -> Vector2i:
	var pos = from
	while true:
		var n = pos + dir
		if static_collider_store.is_occupied_for(n, STATE_COLLIDER_PLAYER_MASK) \
			or movable_collider_store.is_occupied_for(n, STATE_COLLIDER_PLAYER_MASK):
			return pos
		if ice_store.get_collider(n):
			pos += dir
		else:
			return n
	return pos
