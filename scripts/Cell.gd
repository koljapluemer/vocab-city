class_name Cell
extends Node2D

static var prefabCell = load("res://scenes/prefabs/Cell.tscn")
static var prefabMapText = load("res://scenes/prefabs/Text.tscn")

static var textureEmpty = load("res://assets/Kenney_Tiles/tile_0000.png")
static var textureEmptyActive = load("res://assets/Kenney_Tiles/tile_0002.png")
static var textureWater = load("res://assets/Kenney_Tiles/tile_0037.png")

static var textureVocabLevelOne = load("res://assets/Kenney_Tiles/tile_0027.png")
static var textureVocabLevelTwo = load("res://assets/Kenney_Tiles/tile_0028.png")
static var textureVocabLevelThree = load("res://assets/Kenney_Tiles/tile_0029.png")

var mapPos: Vector2
var objects: Dictionary
var state = ""
var targetWord = ""
var nativeWord = ""
var prompt = ""
var node: Area2D
var isActive = false

var sr = {
	"level": 1
}

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


	# Label Text
	var mapText = prefabMapText.instantiate()
	objects["mapText"] = mapText
	node.add_child(mapText)
	mapText.mouse_entered.connect(_on_mouse_entered)
	mapText.mouse_exited.connect(_on_mouse_exited)

# Getter / Setter

func get_level():
	if "level" in sr:
		return sr["level"]
	else:
		return 1

## States

func set_state_empty(_promptString = ""):
	# means empty land
	state = "empty"
	node.get_node("Tile").set_texture(textureEmpty)
	if _promptString != "":
		objects["mapText"].set_text('[center]'+_promptString+'[/center]')
		prompt = _promptString
		objects["mapText"].add_theme_font_size_override("normal_font_size", 26)

func set_state_none():
	# means water
	state = "none"

func set_state_vocab(_targetWord, _nativeWord):
	state = "vocab"
	targetWord = _targetWord
	nativeWord = _nativeWord
	if get_level() == 1:
		node.get_node("Tile").set_texture(textureVocabLevelOne)
	if get_level() == 2:
		node.get_node("Tile").set_texture(textureVocabLevelTwo)
	if get_level() == 3:
		node.get_node("Tile").set_texture(textureVocabLevelThree)
	objects["mapText"].set_text('[center]'+_targetWord+'[/center]')
	prompt = ""
	objects["mapText"].add_theme_font_size_override("normal_font_size", 48)



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
		"prompt": prompt,
		"sr": sr
	}
	return dict

## Hover

func _on_mouse_entered():
	# if vocab, show native word (TODO: seems broken)
	if state == "vocab":
		objects["mapText"].set_text('[center]'+nativeWord+'[/center]')

func _on_mouse_exited():
	# if vocab, show target word again
	if state == "vocab":
		objects["mapText"].set_text('[center]'+targetWord+'[/center]')


## Scoring

func add_score(_score):
	# check if sr.basicScoreCount exists, otherwise create
	if "basicScoreCount" not in sr:
		sr.basicScoreCount = 0
	sr.basicScoreCount += _score

	if sr.basicScoreCount >= 3:
		increase_to_level_two()
	if sr.basicScoreCount >= 6:
		increase_to_level_three()

func increase_to_level_two():
	sr.level = 2
	node.get_node("Tile").set_texture(textureVocabLevelTwo)

func increase_to_level_three():
	sr.level = 3
	node.get_node("Tile").set_texture(textureVocabLevelThree)

