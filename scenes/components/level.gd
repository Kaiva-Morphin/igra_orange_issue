extends STRUCTS.Level


@onready var call_sound = $Call
@onready var cant_sound = $Cant
@onready var rewind_sound = $Rewind
@onready var theme_music = $MainTheme


var powers_unlocked = false

func checkpoint():
	history = []
	var s = take_snapshot()
	initial_state = s

func soft_hard_reset():
	var hist = take_history()
	hist.reverse()
	for h in hist:
		for p : StateData in h:
			p.revert()	

var cant_sound_delay = 0.25

var processing_step = false
var requested_swap = false

@export var dbg_render : bool = false

var player
var tweened_player

@onready var swap_interpolation : TextureRect = $Canvas/PrevSwapState

func _ready() -> void:
	super._ready()
	GAMESTATE.level_controller = self
	GAMESTATE.camera = get_tree().get_nodes_in_group("camera")[0]
	GAMESTATE.player = get_tree().get_nodes_in_group("player")[0]
	player = GAMESTATE.player
	tweened_player = Node2D.new()
	add_child(tweened_player)
	tweened_player.global_position = player.global_position
	CAMERA.on_ready()
	start_new_step()
	get_tree().call_group(STRUCTS.SWAP_REACTION_GROUP, "on_swap", GAMESTATE.worldstate, true)
	GAMESTATE.vignette.animate(0.0, 0.3, 5.0)



var processing_history = []
var processing_revert_stepping = false
var processing_revert_step = 0

func smooth_back(item: StateData, on_end = null, speed_per_tile = UTILS.speed_per_tile) -> bool:
	var pos = item.data.get("pos")
	if pos != null:
		var p = item.ref.global_position
		item.revert()
		item.ref.global_position = p
		var dist = Vector2(UTILS.to_grid(item.ref.global_position) - pos).length()
		UTILS.tween_move(item.ref, pos * UTILS.tile_size, on_end, speed_per_tile * dist)
		return true
	else:
		item.revert()
		return false

func step_relative_speed(s: int) -> float:
	return max(0.1 / pow(1.1, s), 0.0001)


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
var cant_sound_since = 0
var from_prev_step = 0
func _process(_dt: float) -> void:
	if Input.is_action_just_pressed("aquire_powers"):
		powers_unlocked = true
	cant_sound_since += _dt
	from_prev_step += _dt
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
		for i in mouse_collider_store.pos_to_collider.keys():
			spawn_dbg(Vector2(UTILS.from_grid(i)) + Vector2(8, 8), Color(1, 0.7, 0.8))
		# for i in static_collider_store.pos_to_collider.values():
		# 	spawn_dbg(UTILS.from_grid(i.pos), Color(1, 1, 0))
		# for i in static_collider_store.pos_to_collider.keys():
		# 	spawn_dbg(Vector2(UTILS.from_grid(i)) + Vector2(8, 8), Color(1, 1, 1))

	if Input.is_action_just_pressed("checkpoint"):
		checkpoint()

	if process_revert():
		return
	rewind_sound.stop()
	GAMESTATE.canvas.rewind.hide()
	if Input.is_action_just_pressed("swap") && powers_unlocked:
		requested_swap = true
	
	if processing_step:
		return
	elif !player.suppressed:
		player.stop_anim()
	else:
		from_prev_step += _dt
	
	if requested_swap:
		requested_swap = false
		await RenderingServer.frame_post_draw
		var viewport_texture = get_viewport().get_texture()
		var img = viewport_texture.get_image()
		var tex = ImageTexture.create_from_image(img)
		swap_interpolation.texture = tex
		processing_step = true
		var mat : ShaderMaterial = swap_interpolation.material
		mat.set_shader_parameter("radius", 0.0)
		var tween = create_tween()
		tween.tween_property(
			mat,
			"shader_parameter/radius",
			1.0,
			0.8
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
		$Swap.play()
		GAMESTATE.swap()
		return
	
	if Input.is_action_just_pressed("step_back")  && powers_unlocked:
		UTILS.log_prints("[level instance] step_back")
		var h = pop_from_history()
		if h && h.size() > 0:
			$Tick.play(1.2)
			for item in h:
				if smooth_back(item, func(): processing_step = false):
					processing_step = true
		return
	
	if player.suppressed:
		return
	
	player.stop_anim()
	
	if Input.is_action_just_pressed("hard_reset")  && powers_unlocked:
		UTILS.log_print("[level instance] hard reset")
		processing_step = true
		GAMESTATE.vignette.animate(0.4, 0.2, 0.4)
		var t = get_tree().create_timer(0.5)
		$HardReset.play()
		t.timeout.connect(
			func():
				processing_step = false
				soft_hard_reset()
		)
		return
	
	if Input.is_action_just_pressed("reset") && powers_unlocked:
		UTILS.log_print("[level instance] reset")
		var hist = take_history()
		hist.reverse()
		GAMESTATE.canvas.rewind.show()
		rewind_sound.play()
		processing_history = hist
		processing_revert_step = 0
		return
	
	if from_prev_step < UTILS.input_delay:
		return
	
	var i_dir = UTILS.get_input_dir()
	if i_dir == Vector2i.ZERO:
		return
	
	var grid_pos = player.pos;
	var dst_grid = grid_pos + i_dir
	if static_collider_store.is_occupied_for(dst_grid, STATE_COLLIDER_PLAYER_MASK):
		if cant_sound_delay < cant_sound_since:
			cant_sound_since = 0
			cant_sound.play()
		return
	
	# check mouse :D
	var to_check = [
		dst_grid, 
		dst_grid + Vector2i(1, 0), 
		dst_grid + Vector2i(-1, 0), 
		dst_grid + Vector2i(0, 1), 
		dst_grid + Vector2i(0, -1)
	]
	var mouse_on_path = []
	for i in to_check:
		var mc = mouse_collider_store.get_collider(i)
		if mc:
			mouse_on_path.append(mc)



	var m = movable_collider_store.get_collider(dst_grid)
	var i = ice_store.get_collider(dst_grid)
	var p_i = ice_store.get_collider(grid_pos)
	if m && m.is_occupied_for(STATE_COLLIDER_PLAYER_MASK):
		if !movable_collider_store.can_push(m, i_dir, STATE_COLLIDER_PLAYER_MASK):
			UTILS.log_print("[level instance] push blocked")
			if cant_sound_delay < cant_sound_since:
				cant_sound_since = 0
				cant_sound.play()
			return
		start_new_step()
		var m_dst = m.pos + i_dir
		var m_i = ice_store.get_collider(m_dst)

		# // p_i || (
		if m_i and GAMESTATE.worldstate == WorldState.Past:

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
			from_prev_step = 0.0
			UTILS.tween_move(m, UTILS.from_grid(m_dst), func(): processing_step = false, t)
			UTILS.log_print("[push] m_i push")
			return

		movable_collider_store.save_delta(m.pos, m.pos + i_dir)
		movable_collider_store.push_step()

		movable_collider_store.unchecked_move(m.pos, m.pos + i_dir)
		UTILS.log_prints("[push] !m_i push", p_i)

		m.push_step()
		movable_collider_store.unchecked_push_object(m, i_dir)

		UTILS.log_prints("[level instance] move", m.pos, p_i)
		UTILS.tween_move(m, UTILS.from_grid(grid_pos) + i_dir * 2 * UTILS.tile_size, func(): processing_step = false)
		if p_i != null:
			processing_step = true
			from_prev_step = 0.0
			return
	else:
		start_new_step()

	var dst = player.position + Vector2(i_dir * UTILS.tile_size)

	if i and GAMESTATE.worldstate == WorldState.Past:
		UTILS.log_print("[push] slide")
		var end = get_slide_end(grid_pos, i_dir)
		var d = end - grid_pos
		var dist = max(abs(d.x), abs(d.y))
		player.push_step()
		player.pos = end
		player.look_dir(i_dir)
		player.play_walk()
		player.resume_anim()
		var t = get_tree().create_timer(0.25);
		t.timeout.connect(func(): player.stop_anim())
		for mo in mouse_on_path: mo.react_player(dst_grid)
		UTILS.tween_move(player, UTILS.from_grid(end), func(): processing_step = false, dist * UTILS.speed_per_tile)
		processing_step = true
		from_prev_step = 0.0
		return
	player.look_dir(i_dir)

	# if i_dir.x == 0 and i_dir.y == -1:
	# 	player.look_up()
	# if i_dir.x == 0 and i_dir.y == 1:
	# if i_dir.x == -1 and i_dir.y == 0:
	# 	player.look_left()
	# if i_dir.x == 1 and i_dir.y == 0:
	# 	player.look_right()
	player.play_walk(0.15)
	player.resume_anim()
	processing_step = true
	from_prev_step = 0.0
	player.push_step()
	player.pos = player.pos + i_dir
	for mo in mouse_on_path: mo.react_player(dst_grid)
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
