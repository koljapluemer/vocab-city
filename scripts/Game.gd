extends Node2D

@onready var grid = $Grid


func _physics_process(_delta):
	if (Input.is_action_just_pressed("mb_right")):
		var pos = get_global_mouse_position()
		grid.handle_right_click(pos)
	if (Input.is_action_just_pressed("mb_left")):
		pass
		# print("left click on: ", get_global_mouse_position())



func _on_practice_button_pressed():
	var interface = load("res://scenes/prefabs/PracticeInterface.tscn")
	var inst = interface.instantiate()
	add_child(inst)
