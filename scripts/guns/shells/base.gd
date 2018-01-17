extends RigidBody2D

const constants = preload("res://scripts/constants.gd")

const SHAPE_EXTENTS = Vector2(1.5,5.5)
const TIMEOUT = 5
var active = true

var timer = TIMEOUT

func _ready():
    set_collision_layer(constants.BULLET_SHELL_LAYER)
    set_collision_mask(constants.BULLET_SHELL_MASK)
    timer = TIMEOUT

func _process(delta):
    timer -= delta
    if timer <=0:
        queue_free()
