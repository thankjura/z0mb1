extends RigidBody2D

const constants = preload("res://scripts/constants.gd")
const GUN = null

const TIMEOUT = 1

var wait_time = 0

func _ready():
    wait_time = TIMEOUT
    set_collision_layer(constants.GUN_ENTITY_LAYER)
    set_collision_mask(constants.GUN_ENTITY_MASK)
    $area.set_collision_layer(constants.GUN_ENTITY_AREA_LAYER)
    $area.set_collision_mask(constants.GUN_ENTITY_AREA_MASK)
    set_z_index(constants.GUN_ENTITY_Z)

func _collision(body):
    if body.has_method("set_gun"):
        if body.set_gun(load(GUN)):
            queue_free()

func _physics_process(delta):
    if wait_time > 0:
        wait_time -= delta
    else:
        for b in $area.get_overlapping_bodies():
            _collision(b)