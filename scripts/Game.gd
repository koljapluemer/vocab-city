extends Node2D

@onready var grid = $Grid

var practiceUIOpen = false

func _physics_process(_delta):
	if (Input.is_action_just_pressed("mb_right")):
		var pos = get_global_mouse_position()
		grid.handle_right_click(pos)
	if (Input.is_action_just_pressed("mb_left")):
		pass

func _on_practice_button_pressed():
	if practiceUIOpen:
		close_practice_ui()
	else:
		var interface = load("res://scenes/prefabs/PracticeInterface.tscn")
		var inst = interface.instantiate()
		inst.grid = grid.grid
		add_child(inst)
		practiceUIOpen = true

func close_practice_ui():
	get_node("PracticeInterface").queue_free()
	practiceUIOpen = false
	grid.save_grid()
