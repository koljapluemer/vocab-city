class_name Cell
extends Node2D

var prefabCell = load("res://scenes/prefabs/Cell.tscn")
var prefabMapText = load("res://scenes/prefabs/MapText.tscn")

static var textureEmpty = load("res://assets/Kenney_Tiles/tile_0000.png")
static var textureEmptyActive = load("res://assets/Kenney_Tiles/tile_0002.png")
static var vocabLevelOne = load("res://assets/Kenney_Tiles/tile_0027.png")

var mapPos: Vector2
var objects: Array
var state = ""
var targetWord = ""
var nativeWord = ""
var node: Sprite2D
var isActive = false


func _init(_mapPos):
	mapPos = _mapPos
	objects = []
	state = "none"
	node = prefabCell.instantiate()
	node.position = mapPos * Grid.cell_size
	print("init node: ", node, " at ", node.position)

## States

func set_state_empty():
	state = "empty"
	node.set_texture(textureEmpty)
	
func set_state_none():
	state = "none"
	node.queue_free()

func set_state_vocab(parent, _targetWord, _nativeWord):
	state = "vocab"
	targetWord = _targetWord
	nativeWord = _nativeWord
	node.set_texture(vocabLevelOne)
	# create label with target
	var mapText = prefabMapText.instantiate()
	mapText.set_text(targetWord)
	# add half cell size to center the text (but only vertically)
	var adjustedX = mapPos.x * Grid.cell_size + 1
	var adjustedY = mapPos.y * Grid.cell_size + Grid.cell_size / 2
	mapText.position = Vector2(adjustedX, adjustedY)

	objects.append(mapText)
	parent.add_child(mapText)

## Active / Inactive

func set_active():
	isActive = true
	if state == "empty":
		node.set_texture(textureEmptyActive)

func set_inactive():
	isActive = false
	if state == "empty":
		node.set_texture(textureEmpty)

## Saving

func get_dict():
	var dict = {
		"mapPos": mapPos,
		"state": state,
		"targetWord": targetWord,
		"nativeWord": nativeWord
	}
	return dict
