extends STRUCTS.SwapReaction

var suppressed = false
# var in_anim = false
var pos : Vector2i
@onready var sprites : Node2D = $Sprite
@onready var sprite : Sprite2D = $Sprite/Sprite2D
@onready var sprite2 : Sprite2D = $Sprite/Sprite2D2

@onready var cloud_player : AnimationPlayer = $CloudPlayer
@onready var emotion_player : AnimationPlayer = $EmotionPlayer
@onready var suppressed_node : Node2D = $Suppressed
@onready var suppressed2_node : Node2D = $Suppressed2
@onready var particles : CPUParticles2D = $Suppressed/CPUParticles2D

func _level_ready(level: Level, push_initial: bool = true):
	print("[player] level ready for " + self.name)
	pos = UTILS.to_grid(position)
	position = UTILS.from_grid(pos)
	super._level_ready(level, push_initial)

func restore_state(old_state: StateData):
	super.restore_state(old_state)
	pos = old_state.data["pos"]
	sprite.frame = old_state.data.get("frame")
	sprite2.frame = old_state.data.get("frame")
	sprite2.position = old_state.data.get("offset")
	suppressed = old_state.data.get("suppressed")
	process_suppress(suppressed)
	process_swap(GAMESTATE.worldstate)
	position = UTILS.from_grid(pos)

func save_state() -> StateData:
	var s = super.save_state()
	pos = UTILS.to_grid(position)
	s.data["pos"] = pos
	s.data["frame"] = sprite.frame
	s.data["offset"] = sprite2.position
	s.data["suppressed"] = suppressed
	return s



func push_step():
	super.push_step()

var anim_frame = 0
var anim_idx = 2
var looking_dir = 0
var anim_frames = 1
var anim_speed = 1

func update_sprite():
	set_sprite(anim_frame * 4 + anim_idx * 4 + looking_dir)

func set_sprite(frame: int):
	sprite.frame = frame
	sprite2.frame = frame


func look(dir: int):
	looking_dir = dir
	update_sprite()

func reset_anim():
	anim_frame = 0

func set_anim(idx: int, frames: int, speed: float = 0.5):
	anim_speed = speed
	self.anim_idx = idx
	self.anim_frames = frames
	self.anim_frame = self.anim_frame % self.anim_frames
	update_sprite()

func look_dir(dir: Vector2):
	if dir.x == 0 and dir.y < 0:
		look_up()
	if dir.x == 0 and dir.y > 0:
		look_down()
	if dir.x < 0 and dir.y == 0:
		look_left()
	if dir.x > 0 and dir.y == 0:
		look_right()

func play_walk(s: float = 0.15): set_anim(2, 4, s)
func play_idle(s: float = 0.15): set_anim(0, 1, s)
func resume_anim(): anim_paused = false
func look_right():
	looking_dir = 1
	update_sprite()	

func look_up():
	looking_dir = 2
	update_sprite()

func look_left():
	looking_dir = 3
	update_sprite()

func look_down():
	looking_dir = 0
	update_sprite()


@onready var right_emitter = $RightParticles
@onready var left_emitter = $LeftParticles
@onready var up_emitter = $UpParticles
@onready var down_emitter = $DownParticles
@onready var emitters = [right_emitter, left_emitter, up_emitter, down_emitter]

var anim_paused = false
func stop_anim():
	anim_paused = true
	for emitter : CPUParticles2D in emitters:
		emitter.emitting = false


var c = 0
var prev_play = false
func _process(delta: float) -> void:
	if !suppressed && (Input.is_action_just_pressed("meow") || GAMESTATE.touch_meow_just_pressed):
		meow()
	if !anim_paused:
		c += delta
		if c > anim_speed:
			c -= anim_speed
			anim_frame = (anim_frame + 1) % anim_frames
			for emitter : CPUParticles2D in emitters:
				emitter.emitting = false
			if anim_idx == 2:
				match looking_dir:
					0: up_emitter.emitting = true
					1: left_emitter.emitting = true
					2: down_emitter.emitting = true
					3: right_emitter.emitting = true
			update_sprite()
			prev_play = !prev_play
			if prev_play:
				$Step.pitch_scale = randf_range(0.8, 1.2)
				$Step.play()
	GAMESTATE.touch_meow_just_pressed = false



func on_swap(world_state: WorldState, push_step_needed : bool = true):
	super.on_swap(world_state, push_step_needed)
	process_swap(world_state)
	process_suppress(self.suppressed)

func process_swap(to: WorldState):
	for em : CPUParticles2D in emitters:
		if to == WorldState.Past:
			em.color = Color.GRAY
		else:
			em.color = Color("3c854e9c")

func process_suppress(s: bool):
	if s:
		suppressed_node.show()
		suppressed2_node.show()
		sprites.hide()
		cloud_player.play("cloud")
		emotion_player.play("inspect")
		particles.restart()
	else:
		suppressed_node.hide()
		suppressed2_node.hide()
		sprites.show()

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

@onready var meow_node = $Meow

func meow():
	meow_node.pitch_scale = randf_range(0.86, 1.2)
	meow_node.play()
