extends "res://scripts/guns/base.gd"

const BULLET = preload("res://scenes/guns/bullets/ak47_bullet.tscn")
const ENTITY = preload("res://scenes/entities/ak47_entity.tscn")
const SPEED = 1000
const TIMEOUT = 0.1
const OFFSET = Vector2(87, -48)
const AIM_NAME = "aim_ak47"
const VIEWPORT_SHUTTER = 2
const DROP_VELOCITY = Vector2(400,-400)
const DROP_ANGULAR = 1
const RECOIL = Vector2(-200, 0)
const SPREADING = 0.05
const OVERHEAD_TIMEOUT = 3

const ANIM_DEAD_ZONE_BOTTOM = 10

var overheat_time = 0

func _fire_start():
    $shell_particles.set_emitting(true)

func _fire_stop():
    ._fire_stop()
    $shell_particles.set_emitting(false)

func _muzzle_flash():
    $animation_player.play("fire%d" % (randi()%4+1), -1, 2)

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