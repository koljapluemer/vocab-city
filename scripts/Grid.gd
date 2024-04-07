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


func landfill_surrounding_cells(pos):
	var surrounding = [
		Vector2(0, 1),
		Vector2(0, -1),
		Vector2(1, 0),
		Vector2(-1, 0)
	]
	for dir in surrounding:
		var newPos = pos + dir
		# fill in with state empty if it's water (state none)
		if get_cell_state(newPos) == "none" or get_cell_state(newPos) == "empty":
			var cell = get_or_create_cell_at(newPos)
			var prompt_string = "add something related to: \n" + generate_prompt_string_from_surrounding(newPos)
			cell.set_state_empty(prompt_string)
			add_child(cell.node)

	save_grid()


func generate_prompt_string_from_surrounding(pos):
	var surrounding_pos = [
		Vector2(0, 1),
		Vector2(0, -1),
		Vector2(1, 0),
		Vector2(-1, 0)
	]
	var prompt_addition = ""
	for directions in surrounding_pos:
		var surrPos = pos + directions
		if get_cell_state(surrPos) == "vocab":
			prompt_addition += grid[surrPos].targetWord + " "
	return prompt_addition

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
	landfill_surrounding_cells(activeCellPos)
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
		# sr
		if "sr" in save_grid[cell]:
			cell_inst.sr = save_grid[cell]["sr"]
			print("found sr: ", cell_inst.sr)
		# set the state of the cell
		if save_grid[cell]["state"] == "empty":
			var prompt = ""
			if "prompt" in save_grid[cell]:
				prompt = save_grid[cell]["prompt"]
			cell_inst.set_state_empty(prompt)
		elif save_grid[cell]["state"] == "vocab":
			cell_inst.set_state_vocab(save_grid[cell]["targetWord"], save_grid[cell]["nativeWord"])
