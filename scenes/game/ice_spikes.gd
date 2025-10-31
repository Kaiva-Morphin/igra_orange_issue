extends Node2D

var enabled = true
@onready var sprite = $Sprite2D

func _on_gamestate_ready():
	swap(true)

# swap_reaction
func swap(in_future):
	if in_future:
		sprite.region_rect.position.x = 16
		enabled = false
	else:
		sprite.region_rect.position.x = 0
		enabled = true

func is_swap_collider_now():
	return enabled
