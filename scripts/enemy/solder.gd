extends "res://scripts/enemy/base_enemy.gd"

const ATTACK_DISTANSE = 1000
const ATTACK_DAMAGE = 30

const DEFAULT_VECTOR = Vector2(0, -1)

const BULLET = preload("res://scenes/enemy/bullets/enemy_pistol_bullet.tscn")
const BULLET_SPEED = 600

const AIM_SEEK_NODE = "aim"
const GROUND_BLEND_NODE = "ground_blend"
const AIM_BLEND_NODE = "aim_blend"
const WALK_SCALE_NODE = "walk_scale"
const FIRE_NODE = "fire_oneshot"
const DIE_NODE = "die_transition"
const HIT_NODE = "hit_oneshot"
const HIT_ANIM_NODE = "hit_transition"

const MAX_SPEED = 100
const ACCELERATION = 20
const AIM_TIME = 3
const AIM_SPEED = 6
const ATTACK_FOLLOW_TIMEOUT = 2
const AIM_BLEND_TIME = 0.5

const BODY_STRENGTH = 120
const HEAD_STRENGTH = 100

enum DIE_ANIM {
    DEFAULT,
    HEAD_ON_BACK,
    HEAD_ON_FACE
}

enum HIT_ANIM {
    HEAD_BACK,
    HEAD_FACE
}

var aim_blend_timeout = 0
var aim_blend_enabled = false
var aim_timeout = 0
var idle_timeout = 0

onready var bullet_spawn = get_node("base/base/body/sholder_l/forearm_l/hand_l_pistol/pistol/bullet_spawn")
onready var world = get_tree().get_root().get_node("world")

var die_anim = DIE_ANIM.HEAD_ON_BACK

var current_aim_angle = 0

export(int, "left", "stay", "right") var direction = 0 setget _set_direction

func _ready():
    if direction == -1:
        body_scale = Vector2(-$base.scale.x, $base.scale.y)

    $base/base/body/body_area.set_collision_layer(constants.ENEMY_DAMAGE_LAYER)
    $base/base/body/body_area.set_collision_mask(constants.ENEMY_DAMAGE_MASK)
    $base/base/body/head/head_area.set_collision_layer(constants.ENEMY_DAMAGE_LAYER)
    $base/base/body/head/head_area.set_collision_mask(constants.ENEMY_DAMAGE_MASK)

    $base/base/body/body_area.connect("body_entered", self, "_body_hit")
    $base/base/body/head/head_area.connect("body_entered", self, "_head_hit")
    $anim.set_active(true)

func _body_hit(obj):
    if obj.has_method("damage"):
        obj.damage(BODY_STRENGTH)
    if obj.DAMAGE:
        health -= obj.DAMAGE

func _head_hit(obj):
    var back = is_back()

    if obj.has_method("damage"):
        obj.damage(HEAD_STRENGTH)
    if obj.DAMAGE:
        health -= obj.DAMAGE * 2
    if health > 0:
        if obj is RigidBody2D:
            if obj.get_linear_velocity().x > 0 != back:
                print("->")
                print(back)
                print("on face")
                die_anim = DIE_ANIM.HEAD_ON_FACE
                $anim.transition_node_set_current(HIT_ANIM_NODE, HIT_ANIM.HEAD_BACK)
            else:
                print("->")
                print(back)
                print("on back")
                die_anim = DIE_ANIM.HEAD_ON_BACK
                $anim.transition_node_set_current(HIT_ANIM_NODE, HIT_ANIM.HEAD_FACE)
            print(die_anim)
            $anim.oneshot_node_start(HIT_NODE)

func _set_direction(new_direction):
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
    current_aim_angle = lerp(current_aim_angle, rad2deg(DEFAULT_VECTOR.angle_to(v)), AIM_SPEED*delta)
    $anim.timeseek_node_seek(AIM_SEEK_NODE, abs(current_aim_angle))
    if current_aim_angle > 0 and current_aim_angle < 180:
        $base.set_scale(body_scale)
    elif current_aim_angle > -180 and current_aim_angle < 0:
        $base.set_scale(Vector2(-body_scale.x, body_scale.y))

func change_direction(t, new_direction):
    direction = new_direction
    idle_timeout = t

func die():
    _deactivate()
    $base/base/body/body_area.disconnect("body_entered", self, "_body_hit")
    $base/base/body/head/head_area.disconnect("body_entered", self, "_head_hit")
    $anim.oneshot_node_stop(HIT_NODE)
    $anim.transition_node_set_current(DIE_NODE, die_anim)

func _process(delta):
    if not active:
        return

    var is_aim = aim_timeout > 0

    if aim_blend_timeout > 0:
        aim_blend_timeout -= delta
        if aim_blend_timeout < 0:
            aim_blend_timeout = 0

    if is_aim:
        if aim_blend_enabled:
            $anim.blend2_node_set_amount(AIM_BLEND_NODE, (1 - aim_blend_timeout/AIM_BLEND_TIME))
        else:
            if aim_blend_timeout <= 0:
                aim_blend_timeout = AIM_BLEND_TIME
            aim_blend_enabled = true
        if not attacking:
            aim_timeout -= delta * 5
    else:
        if aim_blend_enabled:
            if aim_blend_timeout <= 0:
                aim_blend_timeout = AIM_BLEND_TIME
            aim_blend_enabled = false
        else:
            $anim.blend2_node_set_amount(AIM_BLEND_NODE, (aim_blend_timeout/AIM_BLEND_TIME))

    if attacking:
        if is_aim:
            aim_timeout -= delta
            if aim_timeout <= 0:
                _fire()
            else:
                _aim(delta)
        else:
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
        $anim.timescale_node_set_scale(WALK_SCALE_NODE, abs(velocity.x)*delta*1.2)
        $anim.blend2_node_set_amount(GROUND_BLEND_NODE, 1)
        if velocity.x > 0:
            $base.set_scale(body_scale)
        elif velocity.x < 0:
            $base.set_scale(Vector2(-body_scale.x, body_scale.y))
    else:
        $anim.blend2_node_set_amount(GROUND_BLEND_NODE, 0)
