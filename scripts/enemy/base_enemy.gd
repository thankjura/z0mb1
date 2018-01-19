extends KinematicBody2D

const constants = preload("res://scripts/constants.gd")
const MOVEMENT_SPEED = 50
const STRENGTH = 150
const ATTACK_DISTANSE = 300
const ATTACK_FOLLOW_TIMEOUT = 5
const ATTACK_DAMAGE = 30
const GRAVITY = Vector2(0, 2000)
const MAX_FALL_SPEED = 800

var ATTACK_DISTANSE_SQUARED = pow(ATTACK_DISTANSE, 2)

onready var player = get_parent().get_node("player")
var body_scale
var health = 100
var attacking = false
var attacking_timeout = 0
var active = true
var velocity = Vector2()

func _ready():
    set_collision_layer(constants.ENEMY_LAYER)
    set_collision_mask(constants.ENEMY_MASK)
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
    set_collision_layer(0)
    set_collision_mask(constants.GROUND_LAYER)
    active = false

func die():
    queue_free()

func hit(body):
    if not active:
        return
    health -= body.DAMAGE
    body.damage(STRENGTH)
    if health <= 0:
        die()

func _process(delta):
    _check_attack()
    
    if attacking and attacking_timeout > 0:
        attacking_timeout -= delta
        if attacking_timeout <= 0:
            attacking = false
    
func _physics_process(delta):
    velocity += GRAVITY * delta
    if velocity.y > MAX_FALL_SPEED:
        velocity.y = MAX_FALL_SPEED

    velocity = move_and_slide(velocity)
