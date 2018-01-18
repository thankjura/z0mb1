extends Node2D

const BULLET = null
const ENTITY = null
const SHELL = null
const SPEED = 500
const TIMEOUT = 0.2
const OFFSET = Vector2(40, -10)
const AIM_NAME = "aim_pistol"
const VIEWPORT_SHUTTER = 0
const DROP_VELOCITY = Vector2(400,-400)
const DROP_ANGULAR = 10
const RECOIL = Vector2(0, 0)
const SPREADING = 0.0
const HEAVINES = 0
const EJECT_SHELL_VECTOR = Vector2(0, -200)

const ANIM_DEAD_ZONE_TOP = 0
const ANIM_DEAD_ZONE_BOTTOM = 0

var wait_ready = 0
var fired = false
var camera
var camera_offset

var world
var player

func _ready():
    set_position(OFFSET)
    world = get_tree().get_root().get_node("world")
    player = get_parent().get_owner()

func _get_bullet_vector():
    var out = ($bullet_spawn.global_position - global_position).normalized()
    if SPREADING:
        out = out.rotated(SPREADING - randf()*SPREADING*2)

    return out

func _get_bullet_position(gun_angle):
    return $bullet_spawn.global_position

func _eject_shell():
    if SHELL:
        var v = EJECT_SHELL_VECTOR * rand_range(1, 1.1)
        var s = SHELL.instance()
        s.set_global_position($shell_gate.global_position)
        var global_rot = $shell_gate.global_rotation
        if abs($shell_gate.global_rotation) > PI/2:
            v.x = -v.x
            global_rot = PI - global_rot
        s.set_global_rotation(global_rot)
        s.applied_torque = rand_range(-200, 500)
        world.add_child(s)
        var impulse = v.rotated(global_rot)
        s.apply_impulse(Vector2(0,0), impulse + player.movement.velocity)

func fire(delta, velocity):
    if wait_ready > 0:
        return
    wait_ready = TIMEOUT

    if not fired:
        fired = true
        _fire_start()
    _shutter_camera()
    _muzzle_flash()
    _play_sound()
    var f = BULLET.instance()
    var bullet_velocity = _get_bullet_vector()
    var gun_angle = Vector2(1, 0).angle_to(bullet_velocity)
    _recoil(RECOIL.rotated(bullet_velocity.angle()))
    f.rotate(gun_angle)
    f.set_axis_velocity(bullet_velocity*SPEED+velocity)
    f.set_global_position(_get_bullet_position(gun_angle))
    world.add_child(f)

func _fire_start():
    pass

func _fire_stop():
    if camera:
        camera.set_offset(camera_offset)

func _muzzle_flash():
    pass

func _recoil(recoil_vector):
    player.gun_recoil(recoil_vector)

func _shutter_camera():
    player.shuffle_camera(VIEWPORT_SHUTTER)

func _play_sound():
    if has_node("audio_fire"):
        $audio_fire.play()

func drop():
    if ENTITY:
        var entity = ENTITY.instance()
        entity.set_global_position(global_position)
        if global_position.x <= $bullet_spawn.global_position.x:
            entity.set_angular_velocity(DROP_ANGULAR)
            entity.set_linear_velocity(Vector2(-DROP_VELOCITY.x,DROP_VELOCITY.y))
        else:
            entity.set_angular_velocity(-DROP_ANGULAR)
            entity.set_linear_velocity(DROP_VELOCITY)
        var world = get_tree().get_root().get_node("world")
        world.add_child(entity)
    queue_free()

func _physics_process(delta):
    if wait_ready > 0:
        wait_ready -= delta
    elif fired:
        fired = false
        _fire_stop()