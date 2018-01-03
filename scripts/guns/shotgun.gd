extends "res://scripts/guns/base.gd"

const BULLET = preload("res://scenes/guns/bullets/shotgun_pellet.tscn")
const ENTITY = preload("res://scenes/entities/shotgun_entity.tscn")
const SPEED = 2000
const TIMEOUT = 1
const OFFSET = Vector2(70, 28)
const AIM_NAME = "aim_shotgun"
const DROP_VELOCITY = Vector2(400,-400)
const DROP_ANGULAR = 1
const PELLETS_PER_SHOOT = 10
const RECOIL = Vector2(-1000, 0)

func _ready():
    ._ready()
    _reset_view()
    $anim.connect("animation_finished", self, "_end_animation")

func _end_animation(anim_name):
    if anim_name == "fire":
        get_parent().get_owner().gun_reload()
        $anim.play("reload", -1, 3)

func _create_pellet(spawn_point, bullet_velocity):
    var p = BULLET.instance()
    var v = bullet_velocity.rotated(deg2rad(randf()*6-3))
    v.normalized()
    p.rotate(Vector2(1, 0).angle_to(v))
    p.set_axis_velocity(v*SPEED*(1.2 - (randf()*0.4)))
    p.set_global_position(spawn_point) # + Vector2(randi()%21-10,randi()%21-10))
    var world = get_tree().get_root().get_node("world")
    world.add_child(p)

func fire(delta):
    if wait_ready > 0:
        return
    wait_ready = TIMEOUT

    $audio_fire.play()
    $anim.play("fire", -1, 3)
    var spawn_point = $to.global_position
    var bullet_velocity = (spawn_point - $from.global_position).normalized()
    _recoil(RECOIL.rotated(bullet_velocity.angle()))
    for i in range(0, PELLETS_PER_SHOOT):
        _create_pellet(spawn_point, bullet_velocity)

func _reset_view():
    $anim.set_current_animation("reload")
    $anim.seek($anim.get_current_animation_length())
    $anim.stop(false)
    $flash.set_visible(false)