class_name Cell


static var prefabCell = load("res://scenes/prefabs/Cell.tscn")

static var textureEmpty = load("res://assets/Kenney_Tiles/tile_0000.png")
static var textureEmptyActive = load("res://assets/Kenney_Tiles/tile_0002.png")


var mapPos: Vector2
var objects: Array
var state
var targetWord = ""
var nativeWord = ""
var node: Sprite2D
var isActive = false


func _init(_mapPos):
	mapPos = _mapPos
	objects = []
	state = "none"

func create_node_if_not_existing():
	if node == null:
		node = prefabCell.instantiate()
		node.position = mapPos * Grid.cell_size

func set_state_empty():
	create_node_if_not_existing()
	state = "empty"
	node.set_texture(textureEmpty)
	
func set_state_none():
	state = "none"
	node.queue_free()

func set_active():
	create_node_if_not_existing()
	isActive = true
	if state == "empty":
		node.set_texture(textureEmptyActive)

func set_inactive():
	create_node_if_not_existing()
	isActive = false
	if state == "empty":
		node.set_texture(textureEmpty)
