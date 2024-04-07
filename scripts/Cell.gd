class_name Cell
extends Node2D

static var prefabCell = load("res://scenes/prefabs/Cell.tscn")
static var prefabMapText = load("res://scenes/prefabs/MapText.tscn")

static var textureEmpty = load("res://assets/Kenney_Tiles/tile_0000.png")
static var textureEmptyActive = load("res://assets/Kenney_Tiles/tile_0002.png")
static var textureVocabLevelOne = load("res://assets/Kenney_Tiles/tile_0027.png")
static var textureWater = load("res://assets/Kenney_Tiles/tile_0037.png")

var mapPos: Vector2
var objects: Dictionary
var state = ""
var targetWord = ""
var nativeWord = ""
var prompt = ""
var node: Area2D
var isActive = false


func _init(_mapPos):
	mapPos = _mapPos
	objects = {}
	state = "none"
	node = prefabCell.instantiate()
	node.get_node("Tile").set_texture(textureWater)
	# mapPos to local gives top left corner of cell, but we want center
	var pos_x = mapPos.x * Grid.cell_size + Grid.cell_size / 2.0
	var pos_y = mapPos.y * Grid.cell_size + Grid.cell_size / 2.0
	node.set_position(Vector2(pos_x, pos_y))
	node.mouse_entered.connect(_on_mouse_entered)
	node.mouse_exited.connect(_on_mouse_exited)

## States

func set_state_empty(_promptString = ""):
	# means empty land
	state = "empty"
	node.get_node("Tile").set_texture(textureEmpty)
	if _promptString != "":
		# check if label exists, otherwise create
		if "mapText" not in objects:
			var mapText = prefabMapText.instantiate()
			objects["mapText"] = mapText
			node.add_child(mapText)
		objects["mapText"].get_node("Label").set_text(_promptString)
		prompt = _promptString

func set_state_none():
	# means water
	state = "none"

func set_state_vocab(_targetWord, _nativeWord):
	state = "vocab"
	targetWord = _targetWord
	nativeWord = _nativeWord
	node.get_node("Tile").set_texture(textureVocabLevelOne)
	# create label with target
	var mapText = prefabMapText.instantiate()
	mapText.get_node("Label").set_text(targetWord)
	objects["mapText"] = mapText
	node.add_child(mapText)



## Active / Inactive

func set_active():
	isActive = true
	if state == "empty" or state == "none":
		node.get_node("Tile").set_texture(textureEmptyActive)

func set_inactive():
	isActive = false
	if state == "empty":
		node.get_node("Tile").set_texture(textureEmpty)
	if state == "none":
		node.get_node("Tile").set_texture(textureWater)

## Saving

func get_dict():
	var dict = {
		"mapPos": mapPos,
		"state": state,
		"targetWord": targetWord,
		"nativeWord": nativeWord,
		"prompt": prompt
	}
	return dict

## Hover

func _on_mouse_entered():
	# if vocab, show native word 
	if state == "vocab":
		objects["mapText"].get_node("Label").set_text(nativeWord)

func _on_mouse_exited():
	# if vocab, show target word again
	if state == "vocab":
		objects["mapText"].get_node("Label").set_text(targetWord)
