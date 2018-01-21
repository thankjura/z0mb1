extends KinematicBody2D

const constants = preload("res://scripts/constants.gd")
const MOVEMENT_SPEED = 50
const ATTACK_DISTANSE = 300
const ATTACK_FOLLOW_TIMEOUT = 5
const ATTACK_DAMAGE = 30
const GRAVITY = Vector2(0, 2000)
const MAX_FALL_SPEED = 800

var ATTACK_DISTANSE_SQUARED = pow(ATTACK_DISTANSE, 2)

onready var player = get_parent().get_node("player")
var body_scale
export(int, 10, 1000) var health = 100
var attacking = false
var attacking_timeout = 0
var active = true
var velocity = Vector2()
var recoil = Vector2()

func _ready():
    set_collision_mask(constants.ENEMY_MASK)
    set_collision_layer(constants.ENEMY_LAYER)
    body_scale = $base.scale

func _get_player_direction():
    if player.global_position.x > global_position.x:
        return 1
    else:
        return -1

func is_back():
    return $base.scale != body_scale

func _check_attack():
    if attacking:
        return
    var new_state
    if has_node("visibility_notifier"):
        new_state = $visibility_notifier.is_on_screen() and get_global_position().distance_squared_to(player.global_position) < ATTACK_DISTANSE_SQUARED
    else:
        new_state = get_global_position().distance_squared_to(player.global_position) < ATTACK_DISTANSE_SQUARED

    var b = is_back()
    if new_state:
        if _get_player_direction() == 1:
            if b:
                new_state = false
        else:
            if not b:
                new_state = false

    if new_state and attacking_timeout <= 0:
        attacking = true
        attacking_timeout = ATTACK_FOLLOW_TIMEOUT


func _deactivate():
    set_collision_mask(constants.GROUND_LAYER)
    active = false

func die():
    _deactivate()

func damage(d, v):
    recoil += v / 20
    if active:
        health -= d

func _process(delta):
    if not active:
        return

    if health <= 0:
        die()

    _check_attack()

    if attacking and attacking_timeout > 0:
        attacking_timeout -= delta
        if attacking_timeout <= 0:
            attacking = false

func _physics_process(delta):
    velocity += GRAVITY * delta
    if velocity.y > MAX_FALL_SPEED:
        velocity.y = MAX_FALL_SPEED

    if not active:
        velocity = velocity.linear_interpolate(Vector2(), 20*delta)
    velocity = move_and_slide(velocity + recoil)
    velocity -= recoil
    var new_recoil = recoil.linear_interpolate(Vector2(), 20*delta)
    if sign(recoil.x) != sign(new_recoil.x):
        new_recoil.x = 0
    if sign(recoil.y) != sign(new_recoil.y):
        new_recoil.y = 0
    recoil = new_recoil
