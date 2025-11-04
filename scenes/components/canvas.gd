extends CanvasLayer

@export var vignette: TextureRect
@export var dialog: AnimationPlayer
@export var dialog_label: Label
@export var dialog_bg: AnimationPlayer
@export var rewind: ColorRect

var word_dialog_time := 0.6
var meow_prefix := 0.2

var msgs: Array = []
var current_index := 0
var dialog_timer: Timer

func _ready() -> void:
	GAMESTATE.vignette = self
	GAMESTATE.canvas = self
	
	var m: ShaderMaterial = vignette.material
	m.set_shader_parameter("progress", 0.0)
	m.set_shader_parameter("col", Vector4(0.0, 0.0, 0.0, 1.0))
	
	dialog_timer = Timer.new()
	dialog_timer.one_shot = true
	add_child(dialog_timer)
	dialog_timer.timeout.connect(_on_dialog_timeout)


func start_dialog(new_msgs: Array) -> void:
	if new_msgs.is_empty():
		return
	GAMESTATE.level_ref.call_sound.play()
	msgs = new_msgs
	current_index = 0
	vignette.visible = true
	dialog_bg.play("AnimDialog")
	_show_next_msg()


func _show_next_msg() -> void:
	if current_index >= msgs.size():
		_end_dialog()
		return
	
	var msg = msgs[current_index]
	
	# Считаем время показа в зависимости от количества слов
	var word_count = msg.text.split(" ", false).size()
	var total_time = word_count * word_dialog_time
	
	# Показываем текст и эмоцию сразу
	dialog_label.text = msg.text
	var emotion_name := str(DIALOGS.DialogEmotion.keys()[msg.emotion]).to_lower()
	if dialog.has_animation(emotion_name):
		dialog.play(emotion_name)
	
	# Запускаем таймер: сначала мяу за meow_prefix до конца
	var meow_time = max(total_time - meow_prefix, 0.1)
	dialog_timer.set_meta("data", {"step": "meow", "msg": msg})
	dialog_timer.start(meow_time)


func _on_dialog_timeout() -> void:
	var data = dialog_timer.get_meta("data")
	if data == null:
		return
	
	var step = data.step
	var msg = data.msg
	
	if step == "meow":
		if GAMESTATE.player:
			GAMESTATE.player.meow()
		
		# теперь ждём до конца фразы (остаток meow_prefix)
		dialog_timer.set_meta("data", {"step": "next", "msg": msg})
		dialog_timer.start(meow_prefix)
	
	elif step == "next":
		current_index += 1
		_show_next_msg()


func _end_dialog() -> void:
	dialog_bg.play("hide")
	dialog_timer.stop()


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
			m.set_shader_parameter("col", col), 0.0, 1.0, outro)
