class_name Grid
extends Node


static var cell_size: int = 16

var grid: Dictionary = {}
var editModeActive = false
var activeCellPos = null


# Grid Helper Functions

static func grid_pos_to_pos(_pos: Vector2) -> Vector2:
	return _pos * cell_size
	
static func pos_to_grid_pos(_pos: Vector2) -> Vector2:
	return floor(_pos / cell_size)

func delete_cell_at_grid_pos(pos):
	if !grid.has(pos):
		return
	grid[pos].set_state_none()
	grid.erase(pos)

func get_cell_state(pos):
	if !grid.has(pos):
		return "none"
	return grid[pos].state

func get_or_create_cell_at(mapPos):
	if !grid.has(mapPos):
		grid[mapPos] = Cell.new(mapPos)
	return grid[mapPos]

# Taking input

func handle_right_click(pos):
	var mapPos = Grid.pos_to_grid_pos(pos)
	if get_cell_state(mapPos) == "none":
		var cell = get_or_create_cell_at(mapPos)
		cell.set_state_empty()
		add_child(cell.node)
	# make sidebar visible (except if player clicks activeCell, then hide)
	if activeCellPos != mapPos:
		$SideBar.show()
		set_new_cell_active(mapPos)
	else:
		$SideBar.hide()
		activeCellPos = null
		grid[mapPos].set_inactive()

func set_new_cell_active(mapPos):
	if activeCellPos != null:
		grid[activeCellPos].set_inactive()
	activeCellPos = mapPos
	grid[activeCellPos].set_active()

func _on_button_confirm_pressed():
	if activeCellPos == null:
		return
	var cell = grid[activeCellPos]
	var native = $SideBar.get_node("Panel").get_node("Container").get_node("EditNative").text
	var target = $SideBar.get_node("Panel").get_node("Container").get_node("EditTarget").text
	cell.set_state_vocab(self, target, native)
	# todo: awkward and prone to break
	# add_child(cell.objects[0])

