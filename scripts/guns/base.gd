extends Node2D

const fireball = null
const SPEED = 20
const TIMEOUT = 0.2
const OFFSET = Vector2(40, -10)
const GUN_CLASS = "pistol"

var wait_ready = 0

func _ready():
    set_position(OFFSET)

func get_gun_class():
    return GUN_CLASS

func fire(delta):
    if wait_ready > 0:
        return
    wait_ready = TIMEOUT

    _init_particles(delta)
    var f = fireball.instance()
    f.set_scale(Vector2(0.1, 0.1))

    var spawn_point = $to.global_position
    var fireball_velocity = spawn_point - $from.global_position
    f.rotate(Vector2(1, 0).angle_to(fireball_velocity))
    f.set_axis_velocity(fireball_velocity*SPEED)
    f.set_global_position(spawn_point)
    var world = get_tree().get_root().get_node("world")
    world.add_child(f)

func _init_particles(delta):
    if $particles:
        $particles.set_emitting(true)

func drop():
    _drop()

func _physics_process(delta):
    if wait_ready > 0:
        wait_ready -= delta