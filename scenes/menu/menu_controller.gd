extends Control

@export var main_screen : Control
@export var settings_screen : Control
@export var creds_screen : Control
@export var current_root : Control
@export var next_root : Control
@export var player : AnimationPlayer
@export var music_player : AudioStreamPlayer

@onready var all_screens = [
	main_screen,
	settings_screen,
	creds_screen
]
var current = main_screen
var next
var stack = []
var requested_back = false


func swap_to(to: Control) -> void:
	if to == current: return
	if to != main_screen: stack.push_back(current)
	if player.is_playing(): return
	next = to
	next.show()
	current.show()
	next.reparent(next_root)
	next.position = Vector2.ZERO
	current.reparent(current_root)
	current.position = Vector2.ZERO
	player.play("swap")
	$Sounds/Swap.play()


func back_to_main() -> void:
	stack = []
	swap_to(main_screen)


func back() -> void:
	if stack.size() == 0: return back_to_main()
	swap_to(stack.pop_back())


func detach() -> void:
	current.hide()
	current = next
	next = null
	if requested_back:
		requested_back = false
		back()


func _process(_dt):
	if Input.is_action_pressed("back"):
		if player.is_playing():
			requested_back = true
		else:
			back()


var town_music_resource: AudioStreamWAV = preload("res://assets/sounds/town04.wav")
const MUSIC_NODE_NAME := "TownMusic"

func init_sound() -> void:
	var root = get_tree().get_root()
	var music_node = root.get_node_or_null(MUSIC_NODE_NAME)
	if music_node == null:
		music_node = AudioStreamPlayer.new()
		music_node.name = MUSIC_NODE_NAME
		music_node.stream = town_music_resource
		music_node.volume_db = -36.0
		music_node.bus = "MUSIC"
		music_node.autoplay = false
		root.call_deferred("add_child", music_node)
		call_deferred("_play_music_deferred", music_node)
	else:
		if music_node.get_parent() != root:
			music_node.get_parent().remove_child(music_node)
			root.add_child(music_node)
		music_node.volume_db = -36.0
		call_deferred("_play_music_deferred", music_node)


func _play_music_deferred(music_node: AudioStreamPlayer) -> void:
	if is_instance_valid(music_node):
		music_node.play()


func fade_out_music(duration: float = 2.0) -> void:
	var root = get_tree().get_root()
	var music_node = root.get_node_or_null(MUSIC_NODE_NAME)
	if music_node == null:
		return
	var tween = get_tree().create_tween()
	tween.tween_property(music_node, "volume_db", -80.0, duration)
	tween.tween_callback(Callable(music_node, "stop"))


func _ready() -> void:
	init_sound()
	if DisplayServer.is_touchscreen_available() && !GAMESTATE.touch_inited:
		$Touch.show()
	current = main_screen
	for screen in all_screens:
		if screen == current:
			current.show()
			continue
		screen.hide()
	
	var nodes = get_tree().get_nodes_in_group("ui_button")
	for node in nodes:
		if node is Button:
			node.connect("button_down", _on_btn_down)
			node.connect("button_up", _on_btn_up)
			#node.connect("mouse_entered", _on_btn_unfocus)
			#node.connect("mouse_exited", _on_btn_focus)


func _on_play_pressed() -> void:
	fade_out_music()
	get_tree().paused = false
	get_tree().change_scene_to_packed(STORE.game_scene)


func _on_settings_pressed() -> void:
	swap_to(settings_screen)


func _on_cred_pressed() -> void:
	swap_to(creds_screen)


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_btn_down():
	$Sounds/Pressed.play()


func _on_btn_up():
	$Sounds/Released.play()


func _on_btn_unfocus():
	$Sounds/Unhover.play()


func _on_btn_focus():
	$Sounds/Hover.play()


func _on_yes_pressed() -> void:
	GAMESTATE.touch_enabled = true
	GAMESTATE.touch_inited = true
	$Touch.hide()


func _on_no_pressed() -> void:
	GAMESTATE.touch_enabled = false
	GAMESTATE.touch_inited = false
	$Touch.hide()
