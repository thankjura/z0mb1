extends "res://scripts/enemy/base_enemy.gd"

const ATTACK_DISTANSE = 800
const MOVEMENT_SPEED = 6000
const GRAVITY = Vector2()

const SPY_TIME = 1

var spy = false
var spy_blend = 0
var spy_timeout = 0

func _ready():
    $anim.set_active(true)

func _integrate_forces(s):
    if global_position.distance_squared_to(player.global_position) < ATTACK_DISTANCE_SQUARED:
        spy = true
        spy_timeout = SPY_TIME
    else:
        if spy:
            spy_timeout -=  s.get_step()
            if spy_timeout <= 0:
                spy = false

    if spy:
        if spy_blend < 1:
            spy_blend += s.get_step()
            if spy_blend > 1:
                spy_blend = 1
        s.set_linear_velocity((player.global_position - global_position).normalized() * s.get_step() * MOVEMENT_SPEED)
    else:
        if spy_blend > 0:
            spy_blend -= s.get_step()
            if spy_blend < 0:
                spy_blend = 0
        s.set_linear_velocity(Vector2())

    $anim.blend2_node_set_amount("blend", spy_blend)

func _die_anim_finish():
    queue_free()

func die():
    .die()
    $anim.transition_node_set_current("current_anim", 1)
