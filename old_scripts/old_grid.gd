class_name CellGrid
extends Node2D

var prefabVocabUI = load("res://scenes/prefabs/InterfaceVocab.tscn")
var dialogPrefab = load("res://scenes/prefabs/NewWordDialog.tscn")
var prefabPromptCell = load("res://scenes/prefabs/PromptCell.tscn")
var prefabCell = load("res://scenes/prefabs/Cell.tscn")


static var width: int = 12
static var height: int = 12
static var cell_size: int = 256


@export var show_debug: bool = true

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

func set_cell_background(pos):
	if !grid.has(pos):
		return
	grid[pos].set_cell_background()

func get_cell_state(pos):
	if !grid.has(pos):
		return "empty"
	return grid[pos].state

# Main Loop 

func _ready():
	load_grid()

func _physics_process(_delta):
	if (Input.is_action_just_pressed("mb_right")):
		var pos = get_global_mouse_position()
		var grid_pos = CellGrid.pos_to_grid_pos(pos)
		if !editModeActive &&  get_cell_state(grid_pos) == "empty":
			editModeActive = true
			open_dialog(pos.x, pos.y)
		else:
			delete_cell_at_grid_pos(grid_pos)
			pass


# Misc UI Stuff

func open_dialog(x, y):
	var dialog = dialogPrefab.instantiate()
	var dialogPos = Vector2(x, y)
	activeMapCoords = CellGrid.pos_to_grid_pos(dialogPos)
	dialog.set_position(dialogPos)
	add_child(dialog)
	# confirm button
	var confirmButton = dialog.get_node("ButtonConfirm")
	confirmButton.pressed.connect(_on_dialog_confirm)
	# cancel button
	var cancelButton = dialog.get_node("ButtonCancel")
	cancelButton.pressed.connect(_on_dialog_cancel)

func _on_dialog_confirm():
	var native_word = get_node("NewWordDialog").get_node("EditNative").text
	var target_word =  get_node("NewWordDialog").get_node("EditTarget").text
	add_vocab_node(native_word, target_word, activeMapCoords.x, activeMapCoords.y)
	var mapPos = Vector2(activeMapCoords.x, activeMapCoords.y)
	mark_neighbor_tiles(mapPos)	
	save_grid()
	close_dialog()


func _on_dialog_cancel():
	close_dialog()

func close_dialog():
	editModeActive = false
	var dialog = get_node("NewWordDialog")
	dialog.queue_free()

func add_vocab_node(native_word, target_word, x, y):
	var gridPos = Vector2(x, y)
		
	var ui_obj = prefabVocabUI.instantiate()
	var textPos = CellGrid.grid_pos_to_pos(gridPos)
	ui_obj.set_position(textPos)
	ui_obj.get_node("LabelTarget").text = target_word
	ui_obj.get_node("LabelNative").text = native_word
	add_child(ui_obj)
	
	edit_cell(gridPos, "vocab", [ui_obj])

func mark_neighbor_tiles(pos):
	var neighbor_positions = [
		Vector2(pos.x + 1, pos.y),
		Vector2(pos.x - 1, pos.y),
		Vector2(pos.x, pos.y + 1),
		Vector2(pos.x, pos.y -1),
	]
	for p in neighbor_positions:
		var words = analyze_neighbors(p)
		if len(words) > 0:
			var real_pos = grid_to_world(p)
			var prompt_string = "Add something related to "
			var i = 0
			for word in words:
				if i > 0:
					prompt_string += " and "
				prompt_string += word
				i += 1
			
			var generate_prompt_obj = false

			if p not in grid:
				grid[p] = {}
				generate_prompt_obj = true
			else:	

				var cell_content = grid[p]
				# we want a new prompt cell if the cell is null
				if get_cell_state(p) == "empty":
					generate_prompt_obj = true
				# also we want to overwrite shorter prompts
				if "state" in cell_content:
					if cell_content.state == "prompt":
						if len(cell_content.objects[0].obj.text) < len(prompt_string):
							delete_cell_at_grid_pos(p)
							generate_prompt_obj = true
			
			if generate_prompt_obj:
				add_prompt_cell(real_pos, prompt_string)
				
				

func add_prompt_cell(pos, prompt_string):
	var prompt = prefabPromptCell.instantiate()
	prompt.position = pos
	var label = prompt.get_node("Label")
	label.text = prompt_string
	add_child(prompt)
	edit_cell(pos, "prompt", [prompt])
	
	
func analyze_neighbors(pos):
	var neighboring_words = []
	var positions_to_check = [
		Vector2(pos.x + 1, pos.y),
		Vector2(pos.x - 1, pos.y),
		Vector2(pos.x, pos.y + 1),
		Vector2(pos.x, pos.y -1),
	]
	for p in positions_to_check:
		if p in grid:
			if "state" in grid[p]:
				if grid[p].state == "vocab":
					var vocab = grid[p]
					neighboring_words.append(vocab["data"].target_word)
	return neighboring_words
	

# Saving and Loading
func save_grid():
	var save_game = FileAccess.open("user://vocab-city-grid.save", FileAccess.WRITE)
	save_game.store_var(grid)

func load_grid():
	
	var path = "user://vocab-city-grid.save"
	if not FileAccess.file_exists(path):
		print("no save file found")
		return

	var save_game = FileAccess.open(path, FileAccess.READ)
	grid = save_game.get_var()
	for cell in grid:
		if grid[cell].has("state"):
			if grid[cell]["state"] == "vocab":
				add_vocab_node(grid[cell]["data"]["native_word"], grid[cell]["data"]["target_word"], cell.x, cell.y)
			if grid[cell]["state"] == "prompt":
				add_prompt_cell(grid_to_world(cell), grid[cell]["data"]["prompt"])
