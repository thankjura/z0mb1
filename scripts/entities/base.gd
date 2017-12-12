extends RigidBody2D

const TIMEOUT = 1
const gun = preload("res://scenes/guns/r8.tscn")

var wait_time = 0

func _ready():
    wait_time = TIMEOUT
    set_z(20)

func _collision(body):
    if wait_time > 0:
        return
    if body.has_method("set_gun"):
        if body.set_gun(gun):
            queue_free()

func _physics_process(delta):
    if wait_time > 0:
        wait_time -= delta

    for b in $area.get_overlapping_bodies():
        _collision(b)