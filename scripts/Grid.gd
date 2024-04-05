class_name Grid
extends Node


static var cell_size: int = 16

var grid: Dictionary = {}
var editModeActive = false
var activeMapCoords 

# Grid Helper Functions

static func grid_pos_to_pos(_pos: Vector2) -> Vector2:
	return _pos * cell_size
	
static func pos_to_grid_pos(_pos: Vector2) -> Vector2:
	return floor(_pos / cell_size)

func delete_cell_at_grid_pos(pos):
	if !grid.has(pos):
		return
	grid[pos].delete()
	grid.erase(pos)

func get_cell_state(pos):
	if !grid.has(pos):
		return "empty"
	return grid[pos].state

func get_or_create_cell_at(mapPos):
	if !grid.has(mapPos):
		grid[mapPos] = Cell.new(mapPos)
	return grid[mapPos]

# Taking input

func handle_right_click(pos):
	print("Handling Right Click in Grid")
	var mapPos = Grid.pos_to_grid_pos(pos)
	var cell = get_or_create_cell_at(mapPos)
	add_child(cell.node)
	print("got cell: ", cell)
	cell.set_state_empty()



