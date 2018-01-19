extends Area2D

const constants = preload("res://scripts/constants.gd")

export(int, "go left", "go right") var direction setget _set_direction
export(float, 0, 20) var timeout

var objects = []

func _set_direction(new_direction):
    if new_direction == 0:
        direction = -1
    else:
        direction = 1

func _ready():
    set_collision_mask(constants.ENEMY_LAYER)
    set_collision_layer(0)
    connect("body_entered", self, "_collision")
    connect("body_exited", self, "_collision_end")

func _collision_end(body):
    if body in objects:
        objects.erase(body)

func _collision(body):
    if body.has_method("change_direction") and not body in objects:
        objects.append(body)
        body.change_direction(timeout, direction)