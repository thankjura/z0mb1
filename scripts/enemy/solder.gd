extends "res://scripts/enemy/base_enemy.gd"

const ATTACK_DISTANCE = 800
const ATTACK_DAMAGE = 30
const BACKSLIDE_DISTANCE = 50

const MAX_SPEED = 100
const MAX_RUN_SPEED = 150
const MAX_JUMP = 600
const ACCELERATION = 10
const AIM_TIME = 3

const DEFAULT_VECTOR = Vector2(0, -1)

const BULLET = preload("res://scenes/enemy/bullets/enemy_pistol_bullet.tscn")
const BULLET_SPEED = 600

const BODY_STRENGTH = 120
const HEAD_STRENGTH = 100

enum STATE {
    IDLE,
    WALK,
    AIM,
    RELOCATE,
    PRE_JUMP,
    JUMP
}

onready var bullet_spawn = get_node("base/base/body/sholder_l/forearm_l/hand_l_pistol/pistol/bullet_spawn")
onready var world = get_tree().get_current_scene()
onready var ray_bottom = get_node("base/base/ray_cast_bottom")
onready var ray_middle = get_node("base/base/ray_cast_middle")
onready var ray_height = get_node("base/base/ray_cast_height")
onready var eyes = get_node("base/base/ray_cast_eyes")

export(int, "left", "stay", "right") var direction = 0 setget _set_init_direction

export(STATE) var current_state = STATE.WALK

var next_state
var next_direction
var switch_state_timeout = 0
var jump_vector = Vector2()
var aim_timeout = 0

func _ready():
    $base/base/body/body_area.set_collision_layer(constants.ENEMY_DAMAGE_LAYER)
    $base/base/body/body_area.set_collision_mask(constants.ENEMY_DAMAGE_MASK)
    $base/base/body/head/head_area.set_collision_layer(constants.ENEMY_DAMAGE_LAYER)
    $base/base/body/head/head_area.set_collision_mask(constants.ENEMY_DAMAGE_MASK)
    eyes.set_collision_mask(constants.ENEMY_SEE_MASK)
    eyes.set_cast_to(Vector2(ATTACK_DISTANCE / scale.x, 0))
    $base/base/body/body_area.connect("body_entered", self, "_body_hit")
    $base/base/body/head/head_area.connect("body_entered", self, "_head_hit")

    if direction != $base.scale.x:
        direction = -direction
        _set_direction(-direction)
    
    next_direction = direction
    next_state = current_state

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

func _get_direction():
    return $base.scale.x

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
    var v = (player.get_node("aim").global_position - bullet_spawn.global_position).normalized()
    var a = $anim.aim(rad2deg(DEFAULT_VECTOR.angle_to(v)), delta)    

func change_direction(t, new_direction):
    current_state = STATE.IDLE
    switch_state_timeout = t
    next_direction = new_direction

func die():
    .die()
    $base/base/body/body_area.disconnect("body_entered", self, "_body_hit")
    $base/base/body/head/head_area.disconnect("body_entered", self, "_head_hit")
    $anim.die()

func _init_jump(height):
    switch_state_timeout = 10
    current_state = STATE.PRE_JUMP
    next_state = STATE.PRE_JUMP
    jump_vector = Vector2(200*direction, -height * 1.8)
    $anim.init_jump()

func _start_jump():
    $anim.pause_jump()
    velocity += jump_vector
    current_state = STATE.JUMP
    next_state = STATE.WALK

func _end_jump():
    switch_state_timeout = 0
    next_state = STATE.WALK

func _is_player_visible():
    eyes.look_at(player.get_node("aim").global_position)
    if eyes.is_colliding():
        var o = eyes.get_collider()
        if o == player or o.get_owner() == player:
            return true
    return false

func _process(delta):
    if dead:
        return

    if current_state != next_state:
        switch_state_timeout -= delta
        if switch_state_timeout < 0:
            current_state = next_state
            _set_direction(next_direction)

    var check_attacking = false
    
    if current_state != STATE.JUMP:        
        if player.global_position.x > global_position.x:
            if $base.scale.x == 1:
                check_attacking = true
        else:
            if $base.scale.x == -1:
                check_attacking = true
            
    if check_attacking and _is_player_visible():        
        if current_state != STATE.AIM:
            current_state = STATE.AIM
            next_state = STATE.WALK
            aim_timeout = AIM_TIME
            $anim.idle()
        switch_state_timeout = AIM_TIME

    if current_state == STATE.AIM:
        if aim_timeout <= 0:
            _fire()
            aim_timeout = AIM_TIME
        else:
            aim_timeout -= delta

    if current_state == STATE.JUMP and is_on_floor() and velocity.y == 0:
        current_state = STATE.IDLE
        next_state = STATE.WALK
        switch_state_timeout = 0.2
        $anim.play_jump()

    if current_state == STATE.WALK and is_on_floor() and (ray_bottom.is_colliding() or ray_middle.is_colliding()):
        var p = ray_height.get_collision_point()
        var h = ray_height.cast_to.y - (p.y - ray_height.global_position.y)
        if h < MAX_JUMP:
            _init_jump(h)
        else:
            change_direction(1, -direction)

func _physics_process(delta):
    if dead:
        return

    if current_state == STATE.WALK:
        velocity.x = lerp(velocity.x, MAX_SPEED * direction, ACCELERATION*delta)
    elif current_state == STATE.JUMP:
        velocity.x = lerp(velocity.x, jump_vector.x, ACCELERATION*delta)
    else:
        velocity.x = lerp(velocity.x, 0, ACCELERATION*delta)

    if current_state == STATE.AIM:
        if player.global_position.x > global_position.x:
            _set_direction(1)
        else:
            _set_direction(-1)
        _aim(delta)
    else:
        if is_on_floor():
            $anim.walk(abs(velocity.x)*delta)