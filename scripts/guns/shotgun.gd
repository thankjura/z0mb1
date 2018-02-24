extends "res://scripts/guns/base.gd"

const BULLET = preload("res://scenes/guns/bullets/shotgun_pellet.tscn")
const ENTITY = preload("res://scenes/entities/shotgun_entity.tscn")
const SHELL = preload("res://scenes/guns/shells/shotgun_shell.tscn")
const SPEED = 2000
const TIMEOUT = 1
const OFFSET = Vector2(104, -22)
const CLIMB_OFFSET = Vector2(3, -25)
const AIM_NAME = "aim_shotgun"
const DROP_VELOCITY = Vector2(400,-400)
const DROP_ANGULAR = 1
const PELLETS_PER_SHOOT = 10
const RECOIL = Vector2(-300, 0)
const VIEWPORT_SHUTTER = 3
const HEAVINES = 0.3
const EJECT_SHELL_VECTOR = Vector2(0, -300)

const ANIM_DEAD_ZONE_BOTTOM = 15

func _ready():
    _reset_view()
    $anim.connect("animation_finished", self, "_end_animation")

func _end_animation(anim_name):
    if anim_name == "fire":
        get_parent().get_owner().gun_reload()
        $anim.play("reload", -1, 3)
        $audio_reload.play()
        _fire_stop()

func _create_pellet(spawn_point, bullet_velocity):
    var p = BULLET.instance()
    var v = bullet_velocity.rotated(deg2rad(randf()*6-3))
    v.normalized()
    p.rotate(Vector2(1, 0).angle_to(v))
    p.set_axis_velocity(v*SPEED*(1.2 - (randf()*0.4)))
    p.set_global_position(spawn_point)
    world.add_child(p)

func fire(delta, velocity):
    if wait_ready > 0:
        return
    wait_ready = TIMEOUT

    $audio_fire.play()
    $anim.play("fire", -1, 5)
    var spawn_point = $bullet_spawn.global_position
    var bullet_velocity = (spawn_point - global_position).normalized()
    _recoil(RECOIL.rotated(bullet_velocity.angle()))
    _shutter_camera()
    for i in range(0, PELLETS_PER_SHOOT):
        _create_pellet(spawn_point, bullet_velocity)

func _reset_view():
    $anim.set_current_animation("reload")
    $anim.seek($anim.get_current_animation_length())
    $anim.stop(false)
    $flash.set_visible(false)