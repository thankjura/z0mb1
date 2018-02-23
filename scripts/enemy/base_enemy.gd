extends KinematicBody2D

const constants = preload("res://scripts/constants.gd")
const GRAVITY = 2000
const MAX_FALL_SPEED = 800
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_FRICTION = 10

onready var player = get_parent().get_node("player")

export(int, 10, 1000) var health = 100

var dead = false
var velocity = Vector2()
var recoil = Vector2()

func _ready():
    set_collision_mask(constants.ENEMY_MASK)
    set_collision_layer(constants.ENEMY_LAYER)

func is_back():
    return $base.scale.x == -1

func die():
    dead = true
    set_collision_mask(constants.GROUND_LAYER)

func damage(d, v):
    recoil += v / 20
    if not dead:
        health -= d

func _process(delta):
    if dead:
        return

    if health <= 0:
        die()

func _physics_process(delta):
    if dead:
        velocity.x = lerp(velocity.x, 0, delta*20)

    velocity.y += GRAVITY * delta
    if velocity.y > MAX_FALL_SPEED:
        velocity.y = MAX_FALL_SPEED

    velocity = move_and_slide(velocity + recoil, FLOOR_NORMAL, false, SLOPE_FRICTION)
    velocity -= recoil
    var new_recoil = recoil.linear_interpolate(Vector2(), 10*delta)
    if sign(recoil.x) != sign(new_recoil.x):
        new_recoil.x = 0
    if sign(recoil.y) != sign(new_recoil.y):
        new_recoil.y = 0
    recoil = new_recoil