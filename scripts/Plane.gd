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
	t += delta * 0.01
	# gradually move to destination
	position = position.lerp(currentDestination, t)
	# if basically at destination
	if position.distance_to(currentDestination) < 1.0:
		switchTarget()

func flyTo(start, destination):
	position = start
	currentDestination = destination
	t = 0.0
	targetPosition = destination
	homePosition = start
	rotation = (destination - start).angle()

func switchTarget():
	t = 0.0
	# toggle destination
	if currentDestination == targetPosition:
		currentDestination = homePosition
		rotation = (homePosition - targetPosition).angle()
	else:
		currentDestination = targetPosition
		rotation = (targetPosition - homePosition).angle()
	
	
