extends TileMap

var targetLabelPrefab = load("res://scenes/prefabs/TargetLabel.tscn")
var dialogPrefab = load("res://scenes/prefabs/NewWordDialog.tscn")
var vocabs = []

var editModeActive = false

func _ready():
	load_vocabs()
	print("TileMap ready")

func _physics_process(_delta):
	if (Input.is_action_just_pressed("mb_left")):
		if !editModeActive:
			editModeActive = true
			#add_vocab_node("Maus", "Mouse", get_global_mouse_position().x, get_global_mouse_position().y)		
		
			open_dialog(get_global_mouse_position().x, get_global_mouse_position().y)
			save_vocabs()

func open_dialog(x, y):
	var dialog = dialogPrefab.instantiate()
	dialog.set_position(Vector2(x, y))
	add_child(dialog)

func add_vocab_node(native_word, target_word, x, y):
	var mapPos = local_to_map(Vector2(x, y))

	# skip if tile is already occupied
	if get_cell_tile_data(0, mapPos):
		print("location occupied")
		return	
	var vocab = Vocab.new(native_word, target_word, x, y)
	vocabs.append(vocab)

	set_cell(0, mapPos, 0, Vector2(0,0))
	
	var targetLabel = targetLabelPrefab.instantiate()	
	var textPos = map_to_local(mapPos)	
	targetLabel.set_position(textPos)
	targetLabel.text = vocab.target_word
	add_child(targetLabel)
	
	
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
		add_vocab_node(node_data.native_word, node_data.target_word, node_data.x, node_data.y)
		
