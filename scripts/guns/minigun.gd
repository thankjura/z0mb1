extends "res://scripts/guns/base.gd"

const BULLET = preload("res://scenes/guns/bullets/minigun_bullet.tscn")
const ENTITY = preload("res://scenes/entities/minigun_entity.tscn")
const SPEED = 1000
const TIMEOUT = 0.1
const OFFSET = Vector2(125, 55)
const AIM_NAME = "aim_minigun"
const VIEWPORT_SHUTTER = 3
const DROP_VELOCITY = Vector2(400,-400)
const DROP_ANGULAR = 1
const RECOIL = Vector2(-300, 0)
const SPREADING = 0.05
const OVERHEAD_TIMEOUT = 3

const ANIM_DEAD_ZONE_TOP = 16

var overheat_time = 0

func _ready():
    _reset_view()

func _reset_view():
    get_node("body/barrel_idle").set_visible(true)
    get_node("body/barrel_run").set_visible(false)
    $flash.set_visible(false)

func _fire_start():
    $shell_particles.set_emitting(true)
    $animation_player.play("fire", -1, 3)

func _fire_stop():
    ._fire_stop()
    $shell_particles.set_emitting(false)
    $animation_player.stop()
    _reset_view()

func _process(delta):
    if fired:
        if overheat_time < OVERHEAD_TIMEOUT:
            overheat_time += delta
            if overheat_time > OVERHEAD_TIMEOUT:
                overheat_time = OVERHEAD_TIMEOUT
    else:
        if overheat_time > 0:
            overheat_time -= delta
            if overheat_time < 0:
                overheat_time = 0
    var c = overheat_time / OVERHEAD_TIMEOUT
    get_node("body/overheat").set_modulate(Color(c,c,c))