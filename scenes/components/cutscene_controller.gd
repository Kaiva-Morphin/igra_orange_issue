extends STRUCTS.LevelstateReaction

var shooted = false
func save_state() -> STRUCTS.StateData:
	var s = super.save_state()
	s.data["shooted"] = shooted
	s.ref = self
	return s

func restore_state(old_state: STRUCTS.StateData):
	super.restore_state(old_state)
	shooted = old_state.data["shooted"]


@export var animator : AnimationPlayer
@export var path : Path2D
@export var late_path : Path2D
@export var init_anim : String
@export var anim : String

enum Stage {
	NotShooted,
	InitAnim,
	FollowPath,
	Animation,
	LatePath,
	PreDone,
	Done
}

func to_follow():
	if stage != Stage.InitAnim:
		return
	stage = Stage.FollowPath

var stage = Stage.NotShooted

func main_anim_done():
	if stage != Stage.Animation:
		return
	stage = Stage.LatePath

func _on_area_2d_body_entered(body: Node2D) -> void:
	if !body.is_in_group("player"): return
	if shooted:
		return
	shooted = true
	GAMESTATE.level_controller.requested_swap = false
	GAMESTATE.player.suppressed = true
	GAMESTATE.player.stop_anim()
	if animator && animator.get_animation(init_anim) != null:
		animator.play(init_anim)
		stage = Stage.InitAnim
		UTILS.log_prints("[cutscene] Playing", init_anim)
	elif path:
		stage = Stage.FollowPath
	elif animator && animator.get_animation(anim) != null:
		animator.play(anim)
		stage = Stage.Animation

var processing = false
var processing_idx = 0
func _process(_delta: float) -> void:
	if processing:
		return
	if stage == Stage.FollowPath:
		if path:
			if processing_idx >= path.curve.point_count:
				GAMESTATE.player.stop_anim()
				stage = Stage.Animation
				return
			var g_pos = path.curve.get_point_position(processing_idx) + path.global_position - Vector2(UTILS.tile_size / 2)
			var d = g_pos - GAMESTATE.player.global_position
			var single_axis = d.x == 0 || d.y == 0
			var dst
			if d.x > d.y:
				dst = Vector2(g_pos.x, GAMESTATE.player.global_position.y)
			else:
				dst = Vector2(GAMESTATE.player.global_position.x, g_pos.y)
			var dist = max(abs(d.x), abs(d.y))

			GAMESTATE.player.look_dir(d)
			GAMESTATE.player.resume_anim()
			GAMESTATE.player.play_walk()

			GAMESTATE.player.pos = UTILS.to_grid(dst)
			processing = true
			UTILS.tween_move(GAMESTATE.player, dst, func(): processing = false, dist / UTILS.tile_size.x * UTILS.speed_per_tile)
			UTILS.log_prints("[cutscene]", processing_idx, d, single_axis, "Going from", GAMESTATE.player.global_position, "to", dst)
			if single_axis:
				processing_idx += 1
	if stage == Stage.Animation:
		if animator:
			animator.play(anim)
		else:
			stage = Stage.LatePath

	if stage == Stage.LatePath:
		print("[cutscene] late path")
		if late_path:
			if processing_idx >= late_path.curve.point_count:
				GAMESTATE.player.stop_anim()
				stage = Stage.PreDone
				return
			var g_pos = late_path.curve.get_point_position(processing_idx) + late_path.global_position - Vector2(UTILS.tile_size / 2)
			var d = g_pos - GAMESTATE.player.global_position
			var single_axis = d.x == 0 || d.y == 0
			var dst
			if d.x > d.y:
				dst = Vector2(g_pos.x, GAMESTATE.player.global_position.y)
			else:
				dst = Vector2(GAMESTATE.player.global_position.x, g_pos.y)
			var dist = max(abs(d.x), abs(d.y))

			GAMESTATE.player.look_dir(d)
			GAMESTATE.player.resume_anim()
			GAMESTATE.player.play_walk()

			GAMESTATE.player.pos = UTILS.to_grid(dst)
			processing = true
			UTILS.tween_move(GAMESTATE.player, dst, func(): processing = false, dist / UTILS.tile_size.x * UTILS.speed_per_tile)
			UTILS.log_prints("[cutscene]", processing_idx, d, single_axis, "Going from", GAMESTATE.player.global_position, "to", dst)
			if single_axis:
				processing_idx += 1
		else:
			stage = Stage.PreDone

	if stage == Stage.PreDone:
		stage = Stage.Done
		GAMESTATE.player.suppressed = false
