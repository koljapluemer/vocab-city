extends CanvasLayer

var targetWordA = ""
var targetWordB = ""
var cell_a
var cell_b

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_close_button_pressed():
	queue_free()

func _on_cancel_button_pressed():
	queue_free()


func _on_connect_button_pressed():
	var connectionText = get_node("Panel/Container/VBox/ConnectionInput").text
	get_parent().finish_connection(cell_a.mapPos, cell_b.mapPos, connectionText)
	queue_free()



func set_cells(cell_a, cell_b):
	targetWordA = cell_a.targetWord
	targetWordB = cell_b.targetWord
	self.cell_a = cell_a
	self.cell_b = cell_b
	get_node("Panel/Container/VBox/QuestionLabel").text = "What is the connection between " + targetWordA + " and " + targetWordB + "?"
