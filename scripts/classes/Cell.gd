class_name Cell


static var prefabCell = load("res://scenes/prefabs/Cell.tscn")


var mapPos: Vector2
var objects: Array
var state
var targetWord = ""
var nativeWord = ""
var node: Sprite2D


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
	node.set_texture(load("res://assets/Kenney_Tiles/tile_0000.png"))
	
func set_state_none():
	state = "none"
	node.queue_free()
