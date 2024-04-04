class_name MapGrid
extends Node2D

var prefabVocabUI = load("res://scenes/prefabs/InterfaceVocab.tscn")
var dialogPrefab = load("res://scenes/prefabs/NewWordDialog.tscn")
var prefabTilePrompt = load("res://scenes/prefabs/TilePrompt.tscn")
var prefabCell = load("res://scenes/prefabs/Cell.tscn")


@export var width: int = 12
@export var height: int = 12
@export var cell_size: int = 256

@export var show_debug: bool = true

var grid: Dictionary = {}
var editModeActive = false
var activeMapCoords 



# Grid Helper Functions

func generate_grid():
	for x in width:
		for y in height:
			grid[Vector2(x,y)] = {}
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

func get_cell_state(_pos: Vector2):
	if grid.has(_pos):
		if grid[_pos].has("state"):
			return grid[_pos].state
	return null

func is_cell_free(_pos: Vector2):
	return get_cell_state(_pos) == null || get_cell_state(_pos) == "empty"

func edit_cell(pos, new_state, objects_to_add):
	print("editing cell at", pos)
	if !grid.has(pos):
		grid[pos] = {}
	grid[pos]["state"] = new_state
	grid[pos]["objects"] = objects_to_add
	if new_state == "vocab":
		grid[pos]["data"] = {
			"native_word": objects_to_add[0].get_node("LabelNative").text,
			"target_word": objects_to_add[0].get_node("LabelTarget").text,
		}
	set_cell_background(pos)

func delete_cell_at_grid_pos(pos):
	if !grid.has(pos):
		return
	if grid[pos].has("bg_obj"):
		grid[pos]["bg_obj"].queue_free()
	if grid[pos].has("objects"):
		for obj in grid[pos]["objects"]:
			obj.queue_free()
	grid.erase(pos)

func set_cell_background(pos):
	if !grid.has(pos):
		return
	print("setting cell bg for", pos)
	var cell_node = prefabCell.instantiate()
	var cell_pos = grid_to_world(pos)
	print("cell pos:", cell_pos)
	cell_node.set_position(cell_pos)
	grid[pos]["bg_obj"] = cell_node
	add_child(cell_node)

# Main Loop 

func _ready():
	load_grid()

func _physics_process(_delta):
	if (Input.is_action_just_pressed("mb_right")):
		var pos = get_global_mouse_position()
		var map_pos = world_to_grid(pos)
		if !editModeActive && is_cell_free(map_pos):
			editModeActive = true
			open_dialog(pos.x, pos.y)
		else:
			#delete_tile(get_global_mouse_position())
			pass


# Misc UI Stuff

func open_dialog(x, y):
	var dialog = dialogPrefab.instantiate()
	var dialogPos = Vector2(x, y)
	activeMapCoords = world_to_grid(dialogPos)
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
	save_grid()
	close_dialog()


func _on_dialog_cancel():
	close_dialog()

func close_dialog():
	editModeActive = false
	var dialog = get_node("NewWordDialog")
	dialog.queue_free()

func add_vocab_node(native_word, target_word, x, y):
	print("adding vocab node:", native_word, target_word, x, y)
	var gridPos = Vector2(x, y)
		
	var ui_obj = prefabVocabUI.instantiate()
	var textPos = grid_to_world(gridPos)
	print("setting text at", textPos)
	ui_obj.set_position(textPos)
	print("ui", ui_obj.name)
	ui_obj.get_node("LabelTarget").text = target_word
	ui_obj.get_node("LabelNative").text = native_word
	add_child(ui_obj)
	
	edit_cell(gridPos, "vocab", [ui_obj])
	mark_neighbor_tiles(gridPos)

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
			var adjusted_pos = Vector2(real_pos.x -50, real_pos.y -50)
			var prompt_string = "Add something related to "
			var i = 0
			for word in words:
				if i > 0:
					prompt_string += " and "
				prompt_string += word
				i += 1
			print("prompt string:", prompt_string)
			if p in grid:
				var cell_content = grid[p]
				print("cell content so far:", cell_content)
				var generate_prompt_obj = false
				# we want a new prompt cell if the cell is null
				if !cell_content:
					generate_prompt_obj = true
				# also we want to overwrite shorter prompts
				if "state" in cell_content:
					if cell_content.state == "prompt":
						print("cell: ", cell_content.objects[0])
						if len(cell_content.objects[0].obj.text) < len(prompt_string):
							delete_cell_at_grid_pos(p)
							generate_prompt_obj = true
				
				
				if generate_prompt_obj:
					var prompt = prefabTilePrompt.instantiate()
					prompt.position = adjusted_pos
					prompt.text = prompt_string
					add_child(prompt)
				else:
					print("type of existing obj ", cell_content.state)
				
	
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
	print("saved")

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
