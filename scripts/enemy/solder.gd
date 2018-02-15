extends "res://scripts/enemy/base_enemy.gd"

const ATTACK_DISTANCE = 1000
const ATTACK_DAMAGE = 30
const BACKSLIDE_DISTANCE = 50

const MAX_SPEED = 100
const MAX_RUN_SPEED = 150
const MAX_JUMP = 400
const ACCELERATION = 20
const AIM_TIME = 3

const DEFAULT_VECTOR = Vector2(0, -1)

const BULLET = preload("res://scenes/enemy/bullets/enemy_pistol_bullet.tscn")
const BULLET_SPEED = 600

const BODY_STRENGTH = 120
const HEAD_STRENGTH = 100

enum STATE {
    IDLE,
    WALK,
    RELOCATE,
    JUMP
}

onready var bullet_spawn = get_node("base/base/body/sholder_l/forearm_l/hand_l_pistol/pistol/bullet_spawn")
onready var world = get_tree().get_root().get_node("world")
onready var ray_bottom = get_node("base/base/ray_cast_bottom")
onready var ray_height = get_node("base/base/ray_cast_height")

export(int, "left", "stay", "right") var direction = 0 setget _set_init_direction

export(STATE) var current_state
var next_state
var switch_state_timeout = 0
export(STATE) var block_behavior = STATE.IDLE

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
        
    next_state = STATE.WALK

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
        if direction == -1:
            $base.set_scale(Vector2(-1,1))
        elif direction == 1:
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
        _set_direction(1)
    elif a > -180 and a < 0:
        _set_direction(-1)

func change_direction(t, new_direction):
    current_state = STATE.IDLE
    switch_state_timeout = t
    _set_direction(new_direction)

func die():
    .die()
    $base/base/body/body_area.disconnect("body_entered", self, "_body_hit")
    $base/base/body/head/head_area.disconnect("body_entered", self, "_head_hit")
    $anim.die()

func _process(delta):
    if dead:
        return
        
    if current_state != next_state:
        switch_state_timeout -= delta
        if switch_state_timeout < 0:
            current_state = next_state
        

func _physics_process(delta):
    if dead:
        return

    if ray_bottom.is_colliding():        
        if block_behavior == STATE.IDLE:
            next_state = STATE.IDLE            
        elif block_behavior == STATE.JUMP:
            var p = ray_height.get_collision_point()
            var h = ray_height.cast_to.y - (p.y - ray_height.global_position.y)
            if h < MAX_JUMP:
                switch_state_timeout = 2
                current_state = STATE.IDLE
                next_state = STATE.JUMP
            else:
                change_direction(1, -direction)
        

    if current_state == STATE.IDLE:
        velocity.x = lerp(velocity.x, 0, ACCELERATION*delta)
    elif current_state == STATE.WALK:
        velocity.x = lerp(velocity.x, MAX_SPEED * direction, ACCELERATION*delta)

    if velocity.x:
        $anim.walk(abs(velocity.x)*delta*1.2)
    else:
        $anim.idle()
