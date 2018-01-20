extends "res://scripts/guns/base.gd"

const BULLET = preload("res://scenes/guns/bullets/minigun_bullet.tscn")
const SHELL = preload("res://scenes/guns/shells/minigun_shell.tscn")
const ENTITY = preload("res://scenes/entities/minigun_entity.tscn")
const SPEED = 1000
const TIMEOUT = 0.1
const OFFSET = Vector2(125, 55)
const AIM_NAME = "aim_minigun"
const VIEWPORT_SHUTTER = 10
const DROP_VELOCITY = Vector2(400,-400)
const DROP_ANGULAR = 1
const RECOIL = Vector2(-200, 0)
const SPREADING = 0.05
const OVERHEAD_TIMEOUT = 3
const HEAVINES = 0.6

const EJECT_SHELL_VECTOR = Vector2(0,300)

const ANIM_DEAD_ZONE_TOP = 16

var overheat_time = 0

func _ready():
    _reset_view()

func _reset_view():
    get_node("body/barrel_idle").set_visible(true)
    get_node("body/barrel_run").set_visible(false)
    $flash.set_visible(false)

func _fire_start():
    $animation_player.play("fire", -1, 3)

func _eject_shell():
    var v = EJECT_SHELL_VECTOR * rand_range(0.8, 1.2)
    var s = SHELL.instance()
    s.set_global_position($shell_gate.global_position)
    s.set_z_index(-20)
    var global_rot = $shell_gate.global_rotation
    if abs($shell_gate.global_rotation) > PI/2:
        v.x = -v.x
        global_rot = PI - global_rot
    s.set_global_rotation(rand_range(-PI, PI))
    world.add_child(s)
    var impulse = v.rotated(global_rot)
    s.apply_impulse(Vector2(0,0), impulse + player.movement.velocity)

func _muzzle_flash():
    _eject_shell()

func _fire_stop():
    ._fire_stop()
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