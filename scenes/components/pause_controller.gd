extends Control


func unpause():
	self.hide()

func pause():
	self.show()

@export var main_screen : Control
@export var settings_screen : Control
@export var current_root : Control
@export var next_root : Control
@export var player : AnimationPlayer
@onready var all_screens = [
	main_screen,
	settings_screen,
]
var current = main_screen
var next
var stack = []
var requested_back = false


func _ready():
	self.hide()
	reset()

func _on_exit_pressed() -> void:
	get_tree().change_scene_to_packed(STORE.menu_scene)

func reset():
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

func _on_btn_down():
	$Sounds/Pressed.play()

func _on_btn_up():
	$Sounds/Released.play()

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
	player.play("swap_alpha")
	$Sounds/Swap.play()



func _on_settings_pressed() -> void:
	swap_to(settings_screen)


func _on_continue_pressed() -> void:
	unpause()

func back_to_main() -> void:
	stack = []
	swap_to(main_screen)


func back() -> void:
	if stack.size() == 0: return back_to_main()
	swap_to(stack.pop_back())

func _process(_dt):
	if Input.is_action_just_pressed("back"):
		if !self.visible:
			pause()
		else:
			if stack.size() == 0:
				unpause()
			if player.is_playing():
				requested_back = true
			else:
				back()

func detach() -> void:
	current.hide()
	current = next
	next = null
	if requested_back:
		requested_back = false
		back()
