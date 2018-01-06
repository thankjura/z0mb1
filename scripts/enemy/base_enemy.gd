extends RigidBody2D

const constants = preload("res://scripts/constants.gd")
const MOVEMENT_SPEED = 50
const MOVEMENT_ANIMATION_SPEED = 1.3
const STRENGTH = 150
const ATTACK_DISTANSE = 100
const ATTACK_DAMAGE = 30
var ATTACK_DISTANSE_SQUARED = pow(ATTACK_DISTANSE, 2)

var player
var direction = 1
var body_scale
var health = 100
var attacking = false
var alive = true
var source_position

func _ready():
    set_collision_layer(constants.ENEMY_LAYER)
    set_collision_mask(constants.ENEMY_MASK)
    player = get_parent().get_node("player")
    body_scale = $body.scale

func _get_direction():
    if player.global_position.x > global_position.x:
        return 1
    else:
        return -1

func die():
    set_collision_layer(0)
    set_collision_mask(constants.GROUND_LAYER)
    alive = false

func hit(body):
    if not alive:
        return
    health -= body.DAMAGE
    body.damage(STRENGTH)
    if health <= 0:
        die()