extends Node

var tile_size : Vector2i = Vector2i(16, 16)

func to_grid(v: Vector2):
	return Vector2i(floor(v.x / tile_size.x), floor(v.y / tile_size.y))

func from_grid(v: Vector2i):
	return v * tile_size
