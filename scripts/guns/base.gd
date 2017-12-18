extends Node2D

const BULLET = null
const ENTITY = null
const SPEED = 500
const TIMEOUT = 0.2
const OFFSET = Vector2(40, -10)
const GUN_CLASS = "pistol"

var wait_ready = 0
var fired = false

func _ready():
    set_position(OFFSET)

func get_gun_class():
    return GUN_CLASS

func fire(delta):
    if wait_ready > 0:
        return
    wait_ready = TIMEOUT

    if not fired:
        fired = true
        _fire_start(delta)

    _muzzle_flash(delta)
    var f = BULLET.instance()
    f.set_scale(Vector2(0.1, 0.1))

    var spawn_point = $to.global_position
    var bullet_velocity = (spawn_point - $from.global_position).normalized()
    f.rotate(Vector2(1, 0).angle_to(bullet_velocity))
    f.set_axis_velocity(bullet_velocity*SPEED)
    f.set_global_position(spawn_point)
    var world = get_tree().get_root().get_node("world")
    world.add_child(f)

func _fire_start(delta):
    return

func _fire_stop(delta):
    return

func _muzzle_flash(delta):
    if $particles:
        $particles.set_emitting(true)

func drop():
    _drop()

func _physics_process(delta):
    if wait_ready > 0:
        wait_ready -= delta
    elif fired:
        fired = false
        _fire_stop(delta)