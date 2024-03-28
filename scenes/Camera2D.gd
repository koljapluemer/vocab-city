extends Camera2D
const MOVE_SPEED = 1000

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("camera_up")):
		global_position += Vector2.UP * delta * MOVE_SPEED
	if (Input.is_action_just_pressed("camera_down")):
		global_position += Vector2.DOWN * delta * MOVE_SPEED
	if (Input.is_action_just_pressed("camera_right")):
		global_position += Vector2.RIGHT * delta * MOVE_SPEED
	if (Input.is_action_just_pressed("camera_left")):
		global_position += Vector2.LEFT * delta * MOVE_SPEED
		
