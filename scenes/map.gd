extends TileMap

var prefabVocabUI = load("res://scenes/prefabs/InterfaceVocab.tscn")
var dialogPrefab = load("res://scenes/prefabs/NewWordDialog.tscn")
var prefabTilePrompt = load("res://scenes/prefabs/TilePrompt.tscn")
var vocabs = []
var marks = []

var editModeActive = false
var activeMapCoords 

var cellDataGrid: Dictionary;


	
func generate_cell_dict_key_from_pos(x,y):
	return str(x) + '_' + str(y)
	
func add_cell(cell):
	cellDataGrid[generate_cell_dict_key_from_pos(cell.x, cell.y)] = cell

func delete_cell_at_pos(x, y):	
	var key = generate_cell_dict_key_from_pos(x,y)
	if key in cellDataGrid:
		for obj in cellDataGrid[key].cellDataObjects:
				obj.obj.queue_free()
		cellDataGrid.erase(key)

func get_cell_at_pos(x, y):
	var key = generate_cell_dict_key_from_pos(x,y)
	if key in cellDataGrid:
		return cellDataGrid[key]
	else:
		return null

func _ready():
	cellDataGrid = {}
	load_vocabs()
	

func _physics_process(_delta):
	if (Input.is_action_just_pressed("mb_right")):
		var pos = get_global_mouse_position()
		if !editModeActive && is_tile_free(local_to_map(pos)):
			editModeActive = true
		
			open_dialog(pos.x, pos.y)
		else:
			delete_tile(get_global_mouse_position())


func delete_tile(pos):
	var mapPos = local_to_map(pos)
	print("deleting tile on pos", pos)
	for vocab in vocabs:
		if (vocab.map_x == mapPos.x && vocab.map_y == mapPos.y):
			print("found vocab obj")
			vocab.ui.queue_free()
			vocabs.erase(vocab)
			save_vocabs()
	set_cell(0, mapPos, 0, Vector2(-1, -1))


func get_vocab_from_map_pos(pos):
	for vocab in vocabs:
		if (vocab.map_x == pos.x && vocab.map_y == pos.y):
			return vocab
	return null

func close_dialog():
	editModeActive = false	
	var dialog = get_node("NewWordDialog")
	dialog.queue_free()

func open_dialog(x, y):
	var dialog = dialogPrefab.instantiate()
	activeMapCoords = local_to_map(Vector2(x, y))
	dialog.set_position(Vector2(x, y))
	add_child(dialog)
	# confirm button
	var confirmButton = dialog.get_node("ButtonConfirm")
	confirmButton.pressed.connect(_on_dialog_confirm)
	# cancel button
	var cancelButton = dialog.get_node("ButtonCancel")
	cancelButton.pressed.connect(_on_dialog_cancel)

func _on_dialog_cancel():
	close_dialog()

func _on_dialog_confirm():
	var native_word = get_node("NewWordDialog").get_node("EditNative").text
	var target_word =  get_node("NewWordDialog").get_node("EditTarget").text
	add_vocab_node(native_word, target_word, activeMapCoords.x, activeMapCoords.y)
	save_vocabs()	
	close_dialog()

func is_tile_free(mapPos):
	return !get_cell_tile_data(0, mapPos)

func add_vocab_node(native_word, target_word, x, y):

	# skip if tile is already occupied
	if !is_tile_free(Vector2(x, y)):
		print("location occupied")
		return	
		
	var ui_obj = prefabVocabUI.instantiate()
	var textPos = map_to_local(Vector2(x, y))	
	ui_obj.set_position(Vector2(textPos.x - 64, textPos.y - 100))
	print("ui", ui_obj.name)
	ui_obj.get_node("LabelTarget").text = target_word
	ui_obj.get_node("LabelNative").text = native_word
	add_child(ui_obj)
	
	var vocab = Vocab.new(native_word, target_word, x, y, ui_obj)
	vocabs.append(vocab)

	set_cell(0, Vector2(x, y), 0, Vector2(0,0))
	
	mark_neighbor_tiles(Vector2(x, y))
	

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
			var real_pos = map_to_local(p)
			var adjusted_pos = Vector2(real_pos.x -50, real_pos.y -50)
			var prompt_string = "Add something related to "
			var i = 0
			for word in words:
				if i > 0:
					prompt_string += " and "
				prompt_string += word
				i += 1
			print("prompt string:", prompt_string)
			var cell_content = get_cell_at_pos(p.x, p.y)
			print("cell content so far:", cell_content)
			var generate_prompt_obj = false
			# we want a new prompt cell if the cell is null
			if !cell_content:
				generate_prompt_obj = true
			# also we want to overwrite shorter prompts
			if cell_content:
				if cell_content.state == "prompt": 
					print("cell: ", cell_content.cellDataObjects[0])
					if len(cell_content.cellDataObjects[0].obj.text) < len(prompt_string):
						delete_cell_at_pos(p.x, p.y)
						generate_prompt_obj = true
				
				
			if generate_prompt_obj:
				var prompt = prefabTilePrompt.instantiate()
				var cell = CellData.new(p.x, p.y, "prompt")
				add_cell(cell)
				prompt.position = adjusted_pos
				prompt.text = prompt_string
				add_child(prompt)
				cell.append_obj(CellDataObj.new(prompt))
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
		var vocab = get_vocab_from_map_pos(p)
		if vocab:
			neighboring_words.append(vocab.target_word)
	return neighboring_words
	
	
func save_vocabs():
	var save_game = FileAccess.open("user://vocab-city-vocabs.save", FileAccess.WRITE)	
	print("saving vocabs")
	for vocab in vocabs:
		var json_string = JSON.stringify(vocab.as_json())
		save_game.store_line(json_string)
		
	print("Game Saved.")
	
		
func load_vocabs():
	print("loading vocabs")
	if not FileAccess.file_exists("user://vocab-city-vocabs.save"):
		print("no save file found")
		return
		
	var save_game = FileAccess.open("user://vocab-city-vocabs.save", FileAccess.READ)	
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()
		print("adding node", node_data)
		
		add_vocab_node(node_data.native_word, node_data.target_word, node_data.map_x, node_data.map_y)
		
