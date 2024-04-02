class_name MapManager


var grid: Dictionary;

func _init():
	grid = {}
	
func dict_key_from_pos(x,y):
	return str(x) + '_' + str(y)
	
func add_cell(cell):
	grid[dict_key_from_pos(cell.x, cell.y)] = cell
	
func get_cell_at_pos(x, y):
	var key = dict_key_from_pos(x,y)
	if key in grid:
		return grid[key]
	else:
		return null
