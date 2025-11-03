extends CanvasLayer

@export var vignette: TextureRect

func _ready() -> void:
	GAMESTATE.vignette = self
	var m: ShaderMaterial = vignette.material
	m.set_shader_parameter("progress", 0.0)
	m.set_shader_parameter("col", Vector4(0.0, 0.0, 0.0, 1.0))


func animate(
	intro: float,
	time: float,
	outro: float,
	intro_color_start: Vector4 = Vector4(0.0, 0.0, 0.0, 1.0),
	intro_color_end: Vector4 = Vector4(0.0, 0.0, 0.0, 1.0),
	time_color_end: Vector4 = Vector4(0.0, 0.0, 0.0, 1.0),
	outro_color_end: Vector4 = Vector4(0.0, 0.0, 0.0, 1.0)
) -> void:
	var m: ShaderMaterial = vignette.material
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	m.set_shader_parameter("col", intro_color_start)
	m.set_shader_parameter("progress", 0.0)
	tween.tween_method(
		func(value):
			m.set_shader_parameter("progress", value)
			var col = intro_color_start.lerp(intro_color_end, value)
			m.set_shader_parameter("col", col)
	, 0.0, 1.0, intro)

	tween.tween_interval(time)
	m.set_shader_parameter("col", time_color_end)

	tween.tween_method(
		func(value):
			m.set_shader_parameter("progress", 1.0 - value)
			var col = time_color_end.lerp(outro_color_end, value)
			m.set_shader_parameter("col", col)
	, 0.0, 1.0, outro)