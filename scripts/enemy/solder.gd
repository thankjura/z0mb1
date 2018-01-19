extends "res://scripts/enemy/base_enemy.gd"

const DEFAULT_VECTOR = Vector2(0, -1)

const BULLET = preload("res://scenes/enemy/bullets/enemy_pistol_bullet.tscn")
const BULLET_SPEED = 600

const AIM_SEEK_NODE = "aim"
const GROUND_BLEND_NODE = "ground_blend"
const AIM_BLEND_NODE = "aim_blend"
const WALK_SCALE_NODE = "walk_scale"

const MAX_SPEED = 100
const ACCELERATION = 20
const RELOAD_TIME = 5
const AIM_TIME = 3
const AIM_SPEED = 6

var aim_timeout = 0
var reload_timeout = 0

onready var bullet_spawn = get_node("base/body/sholder_l/forearm_l/hand_l_pistol/pistol/bullet_spawn")
onready var world = get_tree().get_root().get_node("world")

var current_aim_angle = 0

export(int, "left", "stay", "right") var direction = 0 setget _set_direction

func _ready():
    if direction == -1:
        body_scale = Vector2(-$base.scale.x, $base.scale.y)
    $anim.set_active(true)

func _set_direction(new_direction):
    direction = new_direction - 1

func _fire():
    var b = BULLET.instance()
    var bullet_from = $base/body/sholder_l/forearm_l/hand_l_pistol/pistol/from

    var bullet_velocity = (bullet_spawn.global_position - bullet_from.global_position).normalized()
    var gun_angle = Vector2(1, 0).angle_to(bullet_velocity)

    b.rotate(gun_angle)
    b.set_axis_velocity(bullet_velocity*BULLET_SPEED+velocity)
    b.set_global_position(bullet_spawn.global_position)
    world.add_child(b)
    reload_timeout = RELOAD_TIME

func _aim(delta):
    var v = (player.get_node("aim").global_position -  bullet_spawn.global_position).normalized()
    current_aim_angle = lerp(current_aim_angle, rad2deg(DEFAULT_VECTOR.angle_to(v)), AIM_SPEED*delta)
    $anim.timeseek_node_seek(AIM_SEEK_NODE, abs(current_aim_angle))
    if current_aim_angle > 0 and current_aim_angle < 180:
        $base.set_scale(body_scale)
    elif current_aim_angle > -180 and current_aim_angle < 0:
        $base.set_scale(Vector2(-body_scale.x, body_scale.y))

func _physics_process(delta):
    if attacking or aim_timeout > 0:
        $anim.blend2_node_set_amount(AIM_BLEND_NODE, 1)
        if aim_timeout <= 0:
            aim_timeout = AIM_TIME
        else:
            aim_timeout -= delta
            if aim_timeout <= 0:
                _fire()
            else:
                _aim(delta)
        if abs(velocity.x) > 0:
            velocity.x = lerp(velocity.x, 0, ACCELERATION*delta)
    else:
        velocity.x = lerp(velocity.x, MAX_SPEED * direction, ACCELERATION*delta)
        $anim.blend2_node_set_amount(AIM_BLEND_NODE, 0)

    if abs(velocity.x) > 5:
        $anim.timescale_node_set_scale(WALK_SCALE_NODE, abs(velocity.x)*delta*1.2)
        $anim.blend2_node_set_amount(GROUND_BLEND_NODE, 1)
        if velocity.x > 0:
            $base.set_scale(body_scale)
        elif velocity.x < 0:
            $base.set_scale(Vector2(-body_scale.x, body_scale.y))
    else:
        print("idle")
        $anim.blend2_node_set_amount(GROUND_BLEND_NODE, 0)
