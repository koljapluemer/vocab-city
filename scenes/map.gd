extends TileMap

func _physics_process(_delta):
	if (Input.is_action_just_pressed("mb_left")):
		var tile: Vector2 = local_to_map(get_global_mouse_position())
		set_cell(0, tile, 0)

	if (Input.is_action_just_pressed("mb_right")):
		var tile: Vector2 = local_to_map(get_global_mouse_position())
		set_cell(0, tile, 1)

		
		