extends TileMap

var targetLabelPrefab = load("res://scenes/prefabs/TargetLabel.tscn")

func _ready():
	print("TileMap ready")

func _physics_process(_delta):
	if (Input.is_action_just_pressed("mb_left")):
		var tile: Vector2 = local_to_map(get_global_mouse_position())
		set_cell(0, tile, 0, Vector2(0, 0))
		var targetLabel = targetLabelPrefab.instantiate()
		targetLabel.set_position(map_to_local(tile))
		targetLabel.text = "mouse"
		add_child(targetLabel)


		
		
