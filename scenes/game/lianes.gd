extends Node2D

var enabled = true
@onready var sprite = $Sprite2D

func _on_gamestate_ready():
	swap(true)

func can_grow() -> bool:
	return GAMESTATE.get_movable_collider(UTILS.to_grid(self.position)) != null


func swap(in_future):
	if in_future:
		if can_grow():
			sprite.region_rect.position.x = 16
			enabled = false
			return
		sprite.region_rect.position.x = 32
		enabled = true
	else:
		sprite.region_rect.position.x = 0
		enabled = false

func is_swap_collider_now():
	return enabled
