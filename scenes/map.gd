extends TileMap

var prefabVocabUI = load("res://scenes/prefabs/InterfaceVocab.tscn")
var dialogPrefab = load("res://scenes/prefabs/NewWordDialog.tscn")
var vocabs = []

var editModeActive = false
var activeMapCoords 

func _ready():
	load_vocabs()
	print("TileMap ready")

func _physics_process(_delta):
	if (Input.is_action_just_pressed("mb_right")):
		var pos = get_global_mouse_position()
		if !editModeActive && is_tile_free(local_to_map(pos)):
			editModeActive = true
		
			open_dialog(pos.x, pos.y)
			save_vocabs()
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
	

	
	
func save_vocabs():
	var save_game = FileAccess.open("user://vocab-city-vocabs.save", FileAccess.WRITE)	
	print("saving vocabs")
	for vocab in vocabs:
		var json_string = JSON.stringify(vocab.as_json())
		save_game.store_line(json_string)
	
		
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
		
