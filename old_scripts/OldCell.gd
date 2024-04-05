
static var prefabCell = load("res://scenes/prefabs/Cell.tscn")


var mapPos: Vector2
var objects
var state
var targetWord = ""
var nativeWord = ""

func _init(pos, cellState):
	mapPos = pos
	objects = []
	state = cellState

func append_obj(obj):
	objects.append(obj)

func append_objects(objs):
	for obj in objs:
		objects.append(obj)

func delete():
	for obj in objects:
		obj.queue_free()

func set_cell_background():
	var cell_node = prefabCell.instantiate()
	var pos = mapPos
	var cell_pos = CellGrid.grid_pos_to_pos(pos)
	cell_node.set_position(cell_pos)
	append_obj(cell_node)


func set_cell_to_vocab(native, target):
	nativeWord = native
	targetWord = target
	var cell_node = prefabCell.instantiate()
	var pos = mapPos
	var cell_pos = CellGrid.grid_pos_to_pos(pos)
	cell_node.set_position(cell_pos)
	append_obj(cell_node)
	var cell_label = cell_node.get_node("CellLabel")
	cell_label.text = targetWord

func set_cell_to_prompt(promptString: String):
	var cell_node = prefabCell.instantiate()
	var pos = mapPos
	var cell_pos = CellGrid.grid_pos_to_pos(pos)
	cell_node.set_position(cell_pos)
	append_obj(cell_node)
	var cell_label = cell_node.get_node("CellLabel")
	cell_label.text = promptString