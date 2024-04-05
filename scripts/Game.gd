extends Node2D

@onready var grid = $Grid


func _physics_process(_delta):
	if (Input.is_action_just_pressed("mb_right")):
		print("Right click")
		var pos = get_global_mouse_position()
		grid.handle_right_click(pos)
		# var cell = load("res://scenes/prefabs/Cell.tscn")
		# var inst = cell.instantiate()
		# inst.set_position(pos)
		# add_child(inst)
