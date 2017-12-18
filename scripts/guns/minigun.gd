extends "res://scripts/guns/base.gd"

const BULLET = preload("res://scenes/guns/bullets/minigun_bullet.tscn")
const ENTITY = preload("res://scenes/entities/minigun_entity.tscn")
const SPEED = 5000
const TIMEOUT = 0.1
const OFFSET = Vector2(90, 40)
const GUN_CLASS = "minigun"
const VIEWPORT_SHUTTER = 10
const DROP_VELOCITY = Vector2(400,-400)
const DROP_ANGULAR = 1

func _ready():
    ._ready()
    _reset_view()

func _muzzle_flash(delta):
    return

func _reset_view():
    get_node("body/barrel_idle").set_visible(true)
    get_node("body/barrel_run").set_visible(false)
    $flash.set_visible(false)

func _fire_start(delta):
    ._fire_start(delta)
    $case_particles.set_emitting(true)
    $anim.play("fire", -1, 3)

func _fire_stop(delta):
    ._fire_stop(delta)
    $case_particles.set_emitting(false)
    $anim.stop()
    _reset_view()