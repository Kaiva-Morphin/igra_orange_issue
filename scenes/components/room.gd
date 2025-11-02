extends Area2D

@export var perfer_zoom = 3.
@onready var area = self.get_node("AREA")
var rect : Rect2;

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	var pos = Vector2(UTILS.from_grid(UTILS.to_grid(area.global_position)))
	var size = area.shape.size
	self.monitoring = true
	rect = Rect2(pos - size * 0.5, pos + size * 0.5)

func _on_body_entered(body):
	print("[room] enter")
	if !body.is_in_group("player"): return
	print("[room] enter player")
	#CAMERA.override_zoom = perfer_zoom
	CAMERA.room_bound_rects.append([perfer_zoom, rect])
func _on_body_exited(body):
	print("[room] exit")
	if !body.is_in_group("player"): return
	#CAMERA.override_zoom = 0.
	CAMERA.room_bound_rects.erase([perfer_zoom, rect])

var d = 0

func _process(delta: float) -> void:
	# if !GAME.enable_opt: return
	d += delta
	if d > 0.25:
		d = 0
		if (self.global_position - GAMESTATE.player.global_position).length_squared() > pow(1800, 2):
			get_parent().hide()
			for c in get_parent().get_children():
				if c is Area2D: continue
				if c.process_mode == Node.PROCESS_MODE_INHERIT:
					c.process_mode = Node.PROCESS_MODE_DISABLED
				#for n in c.get_children():
				#	c.set_process(false)
		else:
			get_parent().show()
			for c in get_parent().get_children():
				if c is Area2D: continue
				c.process_mode = Node.PROCESS_MODE_INHERIT
				#for n in c.get_children():
				#	c.set_process(true)
