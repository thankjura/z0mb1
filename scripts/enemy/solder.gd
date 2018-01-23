extends "res://scripts/enemy/base_enemy.gd"

const ATTACK_DISTANCE = 1000
const ATTACK_DAMAGE = 30

const DEFAULT_VECTOR = Vector2(0, -1)

const BULLET = preload("res://scenes/enemy/bullets/enemy_pistol_bullet.tscn")
const BULLET_SPEED = 600

const MAX_SPEED = 100
const ACCELERATION = 20
const AIM_TIME = 3

const DIRECTION_RIGHT = 1
const DIRECTION_LEFT = -1

const BODY_STRENGTH = 120
const HEAD_STRENGTH = 100

onready var bullet_spawn = get_node("base/base/body/sholder_l/forearm_l/hand_l_pistol/pistol/bullet_spawn")
onready var world = get_tree().get_root().get_node("world")

export(int, "left", "stay", "right") var direction = 0 setget _set_init_direction

# timeouts
var aim_timeout = 0
var idle_timeout = 0

func _ready():
    $base/base/body/body_area.set_collision_layer(constants.ENEMY_DAMAGE_LAYER)
    $base/base/body/body_area.set_collision_mask(constants.ENEMY_DAMAGE_MASK)
    $base/base/body/head/head_area.set_collision_layer(constants.ENEMY_DAMAGE_LAYER)
    $base/base/body/head/head_area.set_collision_mask(constants.ENEMY_DAMAGE_MASK)

    $base/base/body/body_area.connect("body_entered", self, "_body_hit")
    $base/base/body/head/head_area.connect("body_entered", self, "_head_hit")

    if direction != $base.scale.x:
        direction = -direction
        _set_direction(-direction)

func _body_hit(obj):
    if obj.has_method("damage"):
        obj.damage(BODY_STRENGTH)
    if obj.DAMAGE:
        health -= obj.DAMAGE
        if health > 0:
            if obj is RigidBody2D:
                $anim.hit_body(obj.get_linear_velocity())

func _head_hit(obj):
    if obj.has_method("damage"):
        obj.damage(HEAD_STRENGTH)
    if obj.DAMAGE:
        health -= obj.DAMAGE * 2
    if health > 0:
        if obj is RigidBody2D:
            $anim.hit_head(obj.get_linear_velocity())

func _set_direction(new_direction):
    if direction != new_direction:
        direction = new_direction
        if direction == DIRECTION_LEFT:
            $base.set_scale(Vector2(-1,1))
        elif direction == DIRECTION_RIGHT:
            $base.set_scale(Vector2(1,1))

func _set_init_direction(new_direction):
    direction = new_direction - 1

func _fire():
    var b = BULLET.instance()
    var bullet_from = $base/base/body/sholder_l/forearm_l/hand_l_pistol/pistol/from

    var bullet_velocity = (bullet_spawn.global_position - bullet_from.global_position).normalized()
    var gun_angle = Vector2(1, 0).angle_to(bullet_velocity)

    b.rotate(gun_angle)
    b.set_axis_velocity(bullet_velocity*BULLET_SPEED+velocity)
    b.set_global_position(bullet_spawn.global_position)
    world.add_child(b)
    $audio_fire.play()

func _aim(delta):
    var v = (player.get_node("aim").global_position -  bullet_spawn.global_position).normalized()
    var a = $anim.aim(rad2deg(DEFAULT_VECTOR.angle_to(v)), delta)
    if a > 0 and a < 180:
        _set_direction(DIRECTION_RIGHT)
    elif a > -180 and a < 0:
        _set_direction(DIRECTION_LEFT)

func change_direction(t, new_direction):
    _set_direction(new_direction)
    idle_timeout = t

func die():
    _deactivate()
    $base/base/body/body_area.disconnect("body_entered", self, "_body_hit")
    $base/base/body/head/head_area.disconnect("body_entered", self, "_head_hit")
    $anim.die()

func _process(delta):
    if not active:
        return

    if aim_timeout > 0:
        aim_timeout -= delta
        if attacking:
            if aim_timeout <= 0:
                _fire()
            else:
                _aim(delta)
    elif attacking:
        aim_timeout = AIM_TIME

func _physics_process(delta):
    if not active:
        return

    if attacking or aim_timeout > 0:
        if abs(velocity.x) > 0:
            velocity.x = lerp(velocity.x, 0, ACCELERATION*delta)
    elif idle_timeout > 0:
        idle_timeout -= delta
        if abs(velocity.x) > 0:
            velocity.x = lerp(velocity.x, 0, ACCELERATION*delta)
    else:
        velocity.x = lerp(velocity.x, MAX_SPEED * direction, ACCELERATION*delta)

    if abs(velocity.x) > 5:
        $anim.walk(abs(velocity.x)*delta*1.2)
        if velocity.x > 0:
            _set_direction(DIRECTION_RIGHT)
        elif velocity.x < 0:
            _set_direction(DIRECTION_LEFT)
    else:
        $anim.idle()
