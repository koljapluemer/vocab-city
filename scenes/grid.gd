class_name MapGrid
extends Node2D

var prefabVocabUI = load("res://scenes/prefabs/InterfaceVocab.tscn")
var dialogPrefab = load("res://scenes/prefabs/NewWordDialog.tscn")
var prefabTilePrompt = load("res://scenes/prefabs/TilePrompt.tscn")
var prefabCell = load("res://scenes/prefabs/Cell.tscn")


@export var width: int = 12
@export var height: int = 12
@export var cell_size: int = 128

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
			return grid[_pos].contents
	return null

func is_cell_free(_pos: Vector2):
	return get_cell_state(_pos) == null || get_cell_state(_pos) == "empty"

func edit_cell(pos, new_state, objects_to_add):
	if !grid.has(pos):
		grid[pos] = {}
	grid[pos]["state"] = new_state
	grid[pos]["objects"] = objects_to_add
	set_cell_background(pos)


func set_cell_background(pos):
	if !grid.has(pos):
		return
	if !grid[pos].has("bg_obj"):
		print("setting cell bg for", pos)
		var cell_node = prefabCell.instantiate()
		var map_pos = world_to_grid(pos)
		var cell_pos = grid_to_world(map_pos)
		print("cell pos:", cell_pos)
		cell_node.set_position(cell_pos)
		grid[pos]["bg_obj"] = cell_node
		add_child(cell_node)

# Main Loop 

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
	# save_vocabs()
	close_dialog()


func _on_dialog_cancel():
	close_dialog()

func close_dialog():
	editModeActive = false
	var dialog = get_node("NewWordDialog")
	dialog.queue_free()

func add_vocab_node(native_word, target_word, x, y):
	var pos = Vector2(x, y)
	var gridPos = grid_to_world(pos)
	# skip if tile is already occupied
	if !is_cell_free(Vector2(x, y)):
		print("location occupied")
		return
		
	var ui_obj = prefabVocabUI.instantiate()
	var textPos = grid_to_world(gridPos)
	ui_obj.set_position(Vector2(textPos.x - 64, textPos.y - 100))
	print("ui", ui_obj.name)
	ui_obj.get_node("LabelTarget").text = target_word
	ui_obj.get_node("LabelNative").text = native_word
	add_child(ui_obj)
	
	edit_cell(gridPos, "vocab", [ui_obj])
