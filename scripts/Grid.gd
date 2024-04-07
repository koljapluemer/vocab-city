class_name Grid
extends Node

# Setup

static var cell_size: int = 16

var grid: Dictionary = {}
var editModeActive = false
var activeCellPos = null

var nativeInput 
var targetInput

func generate_water_grid():
	# generate 20x20 water tiles (if they are empty)
	for x in range(20):
		for y in range(20):
			var pos = Vector2(x - 10, y - 10)
			if !grid.has(pos):
				var cell = Cell.new(pos)
				grid[pos] = cell
				add_child(cell.node)
	
func _ready():
	load_grid()
	generate_water_grid()
	nativeInput = $SideBar.get_node("Panel").get_node("Container").get_node("EditNative")
	targetInput = $SideBar.get_node("Panel").get_node("Container").get_node("EditTarget")


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
		var cell = Cell.new(mapPos)
		add_child(cell.node)
		grid[mapPos] = cell
	return grid[mapPos]

# Taking input

func handle_right_click(pos):
	var mapPos = Grid.pos_to_grid_pos(pos)
	if get_cell_state(mapPos) == "none":
		var cell = get_or_create_cell_at(mapPos)
		# cell.set_state_empty()
		add_child(cell.node)
	# make sidebar visible (except if player clicks activeCell, then hide)
	if activeCellPos != mapPos:
		$SideBar.show()
		set_new_cell_active(mapPos)
		save_grid()
	else:
		$SideBar.hide()
		activeCellPos = null
		grid[mapPos].set_inactive()
		save_grid()

func set_new_cell_active(mapPos):
	if activeCellPos != null:
		grid[activeCellPos].set_inactive()
	activeCellPos = mapPos
	grid[activeCellPos].set_active()

func reset_side_bar():
	grid[activeCellPos].set_inactive()
	activeCellPos = null	
	# UI Reset
	$SideBar.hide()
	nativeInput.text = ""
	targetInput.text = ""

func _on_button_confirm_pressed():
	if activeCellPos == null:
		return
	var cell = grid[activeCellPos]

	var native = nativeInput.text
	var target = targetInput.text

	cell.set_state_vocab(target, native)
	save_grid()
	reset_side_bar()


func _on_button_cancel_pressed():
	reset_side_bar()





# Saving and Loading
func save_grid():
	var save_game = FileAccess.open("user://vocab-city-grid.save", FileAccess.WRITE)
	var save_grid = {}
	# loop through grid and save each cell as sub-dictionary
	for cell in grid:
		save_grid[cell] = grid[cell].get_dict()
	save_game.store_var(save_grid)
	save_game.close()

func load_grid():
	
	var path = "user://vocab-city-grid.save"
	if not FileAccess.file_exists(path):
		print("no save file found")
		return

	var save_game = FileAccess.open(path, FileAccess.READ)
	var save_grid = save_game.get_var()
	for cell in save_grid:
		# create the correct cell
		var cell_inst = get_or_create_cell_at(cell)
		# set the state of the cell
		if save_grid[cell]["state"] == "empty":
			cell_inst.set_state_empty()
		elif save_grid[cell]["state"] == "vocab":
			cell_inst.set_state_vocab(save_grid[cell]["targetWord"], save_grid[cell]["nativeWord"])
