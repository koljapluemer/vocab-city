extends CanvasLayer

var grid
var filteredGrid = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	for key in grid.keys():
		if grid[key].state == "vocab":
			filteredGrid[key] = grid[key]
	set_random_vocab()


func set_random_vocab():
	var correctGridCell = get_random_vocab()
	# set text of Panel/Container/VBox/QuestionLabel to nativeWord
	var questionEl = get_node("Panel/Container/VBox/QuestionLabel")
	questionEl.text = correctGridCell.nativeWord
	# answer options
	var correctAnswer = correctGridCell.targetWord
	var incorrectAnswer = get_random_vocab().targetWord
	# with 50% probability, swap correct and incorrect answers
	var answer1El = get_node("Panel/Container/VBox/Answer1")
	var answer2El = get_node("Panel/Container/VBox/Answer2")
	if randi() % 2 == 0:
		answer1El.text = correctAnswer
		answer2El.text = incorrectAnswer
	else:
		answer1El.text = incorrectAnswer
		answer2El.text = correctAnswer


func get_random_vocab():
	# filter grid dict for elements of state vocab
	# select a random element from filtered dict:

	var size = filteredGrid.size()
	var random_key = filteredGrid.keys()[randi() % size]
	var el = filteredGrid[random_key]
	return el

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_answer_1_pressed():
	handle_answer_pressed("Panel/Container/VBox/Answer1")


func _on_answer_2_pressed():
	handle_answer_pressed("Panel/Container/VBox/Answer2")


func handle_answer_pressed(el):
	var valueOfAnswer = get_node(el).text
	set_random_vocab()


func _on_close_button_pressed():
	get_parent().practiceUIOpen = false
	queue_free()

