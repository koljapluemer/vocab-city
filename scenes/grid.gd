class_name MapGrid
extends Node2D

var prefabVocabUI = load("res://scenes/prefabs/InterfaceVocab.tscn")
var dialogPrefab = load("res://scenes/prefabs/NewWordDialog.tscn")
var prefabTilePrompt = load("res://scenes/prefabs/TilePrompt.tscn")


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

func get_cell_content(_pos: Vector2):
	if grid.has(_pos):
		if grid[_pos].has("contents"):
			return grid[_pos].contents
	return null

func is_cell_free(_pos: Vector2):
	return get_cell_content(_pos) == null || get_cell_content(_pos) == "empty"

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
	# add_vocab_node(native_word, target_word, activeMapCoords.x, activeMapCoords.y)
	# save_vocabs()
	close_dialog()


func _on_dialog_cancel():
	close_dialog()

func close_dialog():
	editModeActive = false
	var dialog = get_node("NewWordDialog")
	dialog.queue_free()
