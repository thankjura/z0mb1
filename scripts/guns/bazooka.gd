extends "res://scripts/guns/base.gd"

const BULLET = preload("res://scenes/guns/bullets/bazooka_rocket.tscn")
const ENTITY = preload("res://scenes/entities/bazooka_entity.tscn")
const TIMEOUT = 2.5
const OFFSET = Vector2(-24, -40)
const AIM_NAME = "aim_bazooka"
const DROP_VELOCITY = Vector2(300,-300)
const DROP_ANGULAR = 1
const RECOIL = Vector2(0, 0)
const SPEED = 500
const ACCELERATION = 2000
const VIEWPORT_SHUTTER = 5
const RELOAD_TIMEOUT = 0.3
const HEAVINES = 0.4

var wait_for_reload = 0

const ANIM_DEAD_ZONE_BOTTOM = 36

func _reload():
    get_parent().get_owner().gun_reload()

func fire(delta, velocity):
    if wait_ready > 0:
        return
    wait_ready = TIMEOUT

    if not fired:
        fired = true
        _fire_start()

    _play_sound()
    var f = BULLET.instance()
    var bullet_velocity = _get_bullet_vector()
    var gun_angle = Vector2(1, 0).angle_to(bullet_velocity)
    f.rotate(gun_angle)
    f.set_axis_velocity(bullet_velocity*SPEED + velocity)
    f.set_applied_force(bullet_velocity*ACCELERATION)
    f.set_global_position(_get_bullet_position(gun_angle))
    var world = get_tree().get_root().get_node("world")
    world.add_child(f)
    wait_for_reload = RELOAD_TIMEOUT

func _process(delta):
    if wait_for_reload > 0:
        wait_for_reload -= delta
        if wait_for_reload <= 0:
            _reload()