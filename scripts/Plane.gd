extends Area2D

var currentDestination 
var homePosition
var targetPosition
var startedFlying = false
var t = 0.0

signal plane_arrived

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if startedFlying:
		t += delta * 0.01
		# gradually move to destination
		position = position.lerp(currentDestination, t)
		# if basically at destination
		if position.distance_to(currentDestination) < 4.0:
			get_node("/root/Game").add_money(1)
			queue_free()

func flyTo(start, destination):
	position = start
	currentDestination = destination
	t = 0.0
	targetPosition = destination
	homePosition = start
	rotation = (destination - start).angle()
	startedFlying = true

