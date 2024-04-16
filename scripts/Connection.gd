class_name Connection
extends Node2D

static var planePrefab = load("res://scenes/prefabs/Plane.tscn")

var timer = 0
var home_pos 
var target_pos
var time_to_wait = 8

func _process(delta):
    timer += delta
    # TODO: don't make number of planes static (should be based on number of connections)
    if timer > time_to_wait:
        timer = 0
        time_to_wait = randf_range(5, 15)
        # pick a random connection
        var plane = planePrefab.instantiate()
        get_parent().add_child(plane)
        if randf() > .5:
            plane.flyTo(home_pos, target_pos)
        else:
            plane.flyTo(target_pos, home_pos)

func setPositions(home, target):
    home_pos = home
    target_pos = target
    # randomize the time to wait
    time_to_wait = randf_range(5, 15)