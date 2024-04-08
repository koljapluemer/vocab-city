extends Area2D

var currentDestination 
var homePosition
var targetPosition
var t = 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta * 0.1
	# gradually move to destination
	global_position = global_position.lerp(currentDestination, t)
	print(t)
	if t >= 1:
		print("Arrived at destination")
		t = 0.0
		# toggle destination
		if currentDestination == targetPosition:
			currentDestination = homePosition
		else:
			currentDestination = targetPosition

func flyTo(start, destination):
	global_position = start
	currentDestination = destination
	t = 0.0
	targetPosition = destination
	homePosition = start
