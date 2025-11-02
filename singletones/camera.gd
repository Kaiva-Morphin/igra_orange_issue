extends STRUCTS.LevelstateReaction

@export var follow_speed : float = 0.

var room_bound_rects = []


@export var prefer_zoom = 2.0
@export var override_zoom : float

@export var follow_node : Node2D = null
@export var override_focus_node : Node2D = null

func get_state():
	return [
		GAMESTATE.camera,
		follow_speed,
		prefer_zoom,
		override_zoom,
		follow_node,
		override_focus_node,
		GAMESTATE.camera.global_position,
		GAMESTATE.camera.zoom
	]

func set_state(data):
	if data == []: return
	GAMESTATE.camera = data[0]
	follow_speed = data[1]
	prefer_zoom = data[2]
	override_zoom = data[3]
	follow_node = data[4]
	override_focus_node = data[5]
	GAMESTATE.camera.global_position = data[6]
	GAMESTATE.camera.zoom = data[7]



var shake_time = 0
var shake_time_since = 0
var shake_amp = 0
var shake_vec = Vector2.ZERO
var shake_strength = 0

func on_ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	follow_node = GAMESTATE.player
	update(0.1)
	# GAME.c_state = get_state()

func shake(amp: float, strength: float =1, time: float =1) -> void:
	shake_time = time
	shake_amp = amp
	shake_strength = strength
	shake_time_since = 0

func update(delta: float) -> void:
	if shake_time <= 0: #end shake
		shake_time = 0
		shake_vec = Vector2.ZERO
		shake_amp = 0
		#self.global_position = follow_node.global_position
	else: # shake
		shake_time -= delta
		if shake_time_since <= 0:
			shake_time_since = shake_amp
			shake_vec = Vector2.from_angle(PI * 2 * randf()) * shake_strength
		else:
			shake_time_since -= delta
	var target_zoom
	
	if override_zoom: target_zoom = override_zoom
	elif len(room_bound_rects) != 0: target_zoom = room_bound_rects[len(room_bound_rects)-1][0]
	else: target_zoom = prefer_zoom
	if follow_speed == 0:
		GAMESTATE.camera.zoom = Vector2(target_zoom, target_zoom)
	else:
		GAMESTATE.camera.zoom = lerp(GAMESTATE.camera.zoom, Vector2(target_zoom, target_zoom), delta * follow_speed * 0.5)
	var world_screen_size = GAMESTATE.camera.get_viewport_rect().size / GAMESTATE.camera.zoom * 0.5
	if follow_node:
		if len(room_bound_rects) == 0:
				if follow_speed == 0:
					GAMESTATE.camera.global_position = follow_node.global_position
				else:
					GAMESTATE.camera.global_position = lerp(GAMESTATE.camera.global_position, follow_node.global_position, delta * follow_speed) + shake_vec
		else:
			var room_bound_rect = self.room_bound_rects[len(self.room_bound_rects) - 1][1]
			var room_bonds_left_up = room_bound_rect.position;
			var room_bonds_right_bottom = room_bound_rect.size;
			if !room_bonds_left_up and !room_bonds_right_bottom:
				GAMESTATE.camera.global_position = lerp(GAMESTATE.camera.global_position, follow_node.global_position, delta * follow_speed) + shake_vec
			else:
				var size = (room_bonds_right_bottom - room_bonds_left_up).abs()
				var center =  ( room_bonds_right_bottom + room_bonds_left_up ) / 2.
				var target_position = follow_node.global_position
				if target_position.x + world_screen_size.x > room_bonds_right_bottom.x:
					target_position.x = room_bonds_right_bottom.x - world_screen_size.x
				if target_position.x - world_screen_size.x < room_bonds_left_up.x:
					target_position.x = room_bonds_left_up.x + world_screen_size.x
				if target_position.y - world_screen_size.y < room_bonds_left_up.y:
					target_position.y = room_bonds_left_up.y + world_screen_size.y
				if target_position.y + world_screen_size.y > room_bonds_right_bottom.y:
					target_position.y = room_bonds_right_bottom.y - world_screen_size.y
				if world_screen_size.x * 2. > size.x:
					target_position.x = center.x
				if (world_screen_size.y) * 2. > size.y:
					target_position.y = center.y
				if follow_speed == 0:
					GAMESTATE.camera.global_position = target_position
				else:
					# GAMESTATE.camera.global_position = lerp(GAMESTATE.camera.global_position, target_position, delta * follow_speed)  + shake_vec
					GAMESTATE.camera.global_position = target_position
