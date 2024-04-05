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
	node = prefabCell.instantiate()
	node.position = mapPos * Grid.cell_size
	

func set_state_empty():
	state = "empty"
	#set_texture(load("res://assets/Kenney_Tiles/tile_0000.png"))
