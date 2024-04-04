class_name Grid
extends Node2D


@export var width: int = 12
@export var height: int = 12
@export var cell_size: int = 128

@export var show_debug: bool = true

var grid: Dictionary = {}

func generate_grid():
	for x in width:
		for y in height:
			grid[Vector2(x,y)] = null
			if show_debug:
				var rect = ReferenceRect.new()
				rect.position = grid_to_world(Vector2(x, y))
				rect.size = Vector2(cell_size, cell_size)
				rect.editor_only = false
				add_child(rect)	

func grid_to_world(_pos: Vector2) -> Vector2:
	return _pos * cell_size
	
func world_to_grid(_pos: Vector2) -> Vector2:
	return floor(_pos / cell_size)
