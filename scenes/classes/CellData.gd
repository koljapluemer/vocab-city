class_name CellData

var x: int
var y: int
var cellDataObjects
var state

func _init(x_coord, y_coord, cellState):
	x = x_coord
	y = y_coord
	cellDataObjects = []
	state = cellState

func append_obj(obj):
	cellDataObjects.append(obj)
