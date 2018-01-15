extends Node

const MAX_JUMP_COUNT = 2
const MAX_FALL_SPEED = 800
const MAX_JUMP_SPEED = 800
const INIT_GRAVITY = Vector2(0, 2000)
const INIT_MAX_SPEED = 400

const JUMP_FORCE = 800
const ACCELERATION = 0.6
const AIR_ACCELERATION = 0.1
const RUN_SPEED = 300
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_FRICTION = 20
const DEFAULT_VECTOR = Vector2(0, -1)

const GROUND_BLEND_NODE = "ground_blend"
const WALK_BLEND_NODE = "walk_blend"
const GROUND_SCALE_NODE = "ground_scale"
const WALK_DIRECTION_NODE = "walk_direction"
const RUN_DIRECTION_NODE = "run_direction"
const STATE_NODE = "ground_air_transition"
const AIM_BLEND_NODE = "aim_blend"
const AIM_SWITCH_NODE = "aim_transition"
const SHOTGUN_RELOAD_NODE = "shotgun_reload"
const ANIMATION_WALK_NODE = "anim_walk"
const BAZOOKA_RELOAD_NODE = "bazooka_reload"

const SHOTGUN_RELOAD_IN = 0.1
const SHOTGUN_RELOAD_OUT = 0.1

const AIM_SHOTGUN_NAME = "aim_shotgun"

var MOVEMENT_MODE = 1
var MAX_SPEED = 600
var GRAVITY = INIT_GRAVITY

enum STATE {
    ground,
    jump_up,
    jump_down
}

enum AIM {
    aim_pistol,
    aim_ak47,
    aim_shotgun,
    aim_minigun,
    aim_bazooka,
}

var input
var player
var anim

var jump_count = 0
var velocity = Vector2()

var body_scale

var reload_in_timeout = 0
var reload_in_time = 1
var reload_out_timeout = 0
var reload_out_time = 1
var recoil = Vector2(0, 0)

var air_state = false

func _init(var player, var anim):
    self.player = player
    self.body_scale = player.get_node("base").scale
    self.anim = anim
    self.anim.set_active(true)
    self.input = load("res://scripts/input.gd").new()

func _recalc_mass():
    if player.gun:
        MAX_SPEED = INIT_MAX_SPEED - INIT_MAX_SPEED * player.gun.HEAVINES
        GRAVITY = INIT_GRAVITY + INIT_GRAVITY * player.gun.HEAVINES
    else:
        MAX_SPEED = INIT_MAX_SPEED
        GRAVITY = INIT_GRAVITY

func _ground_state(delta, m = Vector2(), direction = 1):
    air_state = false
    var movement = 0
    if m.x < 0:
        movement = -1
    elif m.x > 0:
        movement = 1
    movement *= MAX_SPEED
    velocity.x = lerp(velocity.x, movement, ACCELERATION)
    if sign(velocity.x) * direction > 0:
        anim.blend2_node_set_amount(WALK_DIRECTION_NODE, 0)
        anim.blend2_node_set_amount(RUN_DIRECTION_NODE, 0)
    else:
        anim.blend2_node_set_amount(WALK_DIRECTION_NODE, 1)
        anim.blend2_node_set_amount(RUN_DIRECTION_NODE, 1)
    if abs(velocity.x) >= RUN_SPEED:
        anim.blend2_node_set_amount(WALK_BLEND_NODE, 1)
    else:
        anim.blend2_node_set_amount(WALK_BLEND_NODE, 0)
    anim.blend2_node_set_amount(GROUND_BLEND_NODE, abs(velocity.x / MAX_SPEED))
    anim.timescale_node_set_scale(GROUND_SCALE_NODE, abs(velocity.x)*delta*1.2)
    anim.transition_node_set_current(STATE_NODE, STATE.ground)

func _air_state(delta, m = Vector2()):
    var movement = 0
    if m.x < 0:
        movement = -1
    elif m.x > 0:
        movement = 1
    movement *= MAX_SPEED
    velocity.x = lerp(velocity.x + recoil.x, movement, AIR_ACCELERATION)

    if velocity.y and air_state:
        if velocity.y > 0:
            anim.transition_node_set_current(STATE_NODE, STATE.jump_down)
        elif velocity.y < 0:
            anim.transition_node_set_current(STATE_NODE, STATE.jump_up)
    else:
        air_state = true

func _look(rad):
    var deg = rad2deg(rad)
    if player.gun:
        anim.timeseek_node_seek("gun_angle", abs(deg))

    if deg > 0 and deg < 180:
        player.get_node("base").set_scale(body_scale)
    elif deg > -180 and deg < 0:
        player.get_node("base").set_scale(Vector2(-body_scale.x, body_scale.y))

func look_default():
    if player.gun:
        anim.timeseek_node_seek("gun_angle", 90)

func jump():
    if jump_count < MAX_JUMP_COUNT:
        jump_count += 1
        velocity.y = -JUMP_FORCE

func set_gun():
    _recalc_mass()
    player.get_node("base/body/sholder_r/forearm_r/hand_r").set_visible(false)
    player.get_node("base/body/sholder_l/forearm_l/hand_l").set_visible(false)
    if player.gun.AIM_NAME == "aim_pistol":
        player.get_node("base/body/sholder_r/forearm_r/hand_r_pistol").set_visible(true)
        player.get_node("base/body/sholder_l/forearm_l/hand_l_pistol").set_visible(true)
    elif player.gun.AIM_NAME == "aim_minigun":
        player.get_node("base/body/sholder_r/forearm_r/hand_r_minigun").set_visible(true)
        player.get_node("base/body/sholder_l/forearm_l/hand_l_minigun").set_visible(true)
    elif player.gun.AIM_NAME in ["aim_shotgun", "aim_ak47", "aim_bazooka"]:
        player.get_node("base/body/sholder_r/forearm_r/hand_r_pistol").set_visible(true)
        player.get_node("base/body/sholder_l/forearm_l/hand_l_shotgun").set_visible(true)

    anim.transition_node_set_current(AIM_SWITCH_NODE, 0)
    anim.transition_node_set_current(AIM_SWITCH_NODE, 1)
    anim.transition_node_set_current(AIM_SWITCH_NODE, AIM[player.gun.AIM_NAME])

func drop_gun():
    _recalc_mass()
    player.get_node("base/body/sholder_r/forearm_r/hand_r").set_visible(true)
    player.get_node("base/body/sholder_l/forearm_l/hand_l").set_visible(true)
    #  For pistol
    player.get_node("base/body/sholder_r/forearm_r/hand_r_pistol").set_visible(false)
    player.get_node("base/body/sholder_l/forearm_l/hand_l_pistol").set_visible(false)
    #  For minigun
    player.get_node("base/body/sholder_r/forearm_r/hand_r_minigun").set_visible(false)
    player.get_node("base/body/sholder_l/forearm_l/hand_l_minigun").set_visible(false)
    #  For shotgun / ak47 / bazooka
    player.get_node("base/body/sholder_l/forearm_l/hand_l_shotgun").set_visible(false)

func gun_reload():
    if player.gun and player.gun.AIM_NAME == AIM_SHOTGUN_NAME:
        _start_gun_reload()
    if player.gun and player.gun.AIM_NAME == "aim_bazooka":
        anim.oneshot_node_start(BAZOOKA_RELOAD_NODE)


func gun_recoil(recoil_vector):
    recoil.x += recoil_vector.x

func is_back():
    return player.get_node("base").scale != body_scale

func _start_gun_reload():
    if player.gun and player.gun.AIM_NAME == AIM_SHOTGUN_NAME:
        reload_in_timeout = SHOTGUN_RELOAD_IN
        reload_in_time = SHOTGUN_RELOAD_IN

func _stop_gun_reload():
    if player.gun and player.gun.AIM_NAME == AIM_SHOTGUN_NAME:
        reload_out_timeout = SHOTGUN_RELOAD_OUT
        reload_out_time = SHOTGUN_RELOAD_OUT

func process(delta):
    if reload_in_timeout > 0:
        anim.blend2_node_set_amount(SHOTGUN_RELOAD_NODE, 1-reload_in_timeout/reload_in_time)
        reload_in_timeout -= delta
        if reload_in_timeout <= 0:
            anim.blend2_node_set_amount(SHOTGUN_RELOAD_NODE, 1)
            _stop_gun_reload()

    if reload_out_timeout > 0:
        anim.blend2_node_set_amount(SHOTGUN_RELOAD_NODE, reload_out_timeout/reload_out_time)
        reload_out_timeout -= delta
        if reload_out_timeout <= 0:
            anim.blend2_node_set_amount(SHOTGUN_RELOAD_NODE, 0)

    velocity += GRAVITY * delta

    var move_vector = input.get_move_vector()
    var direction = move_vector
    if MOVEMENT_MODE == 1:
        if player.gun:
            direction = (player.get_global_mouse_position() - player.gun.get_node("pos").global_position).normalized()
            var dist = abs((player.global_position.x - player.get_global_mouse_position().x))
            if player.get_global_mouse_position().y > player.gun.get_node("pos").global_position.x:
                if dist < player.gun.ANIM_DEAD_ZONE_BOTTOM:
                    direction.x = 0
            else:
                if dist < player.gun.ANIM_DEAD_ZONE_TOP:
                    direction.x = 0
        else:
            direction = input.get_direction(player)

    if player.is_on_floor():
        jump_count = 0
        var d = 0
        if direction.x > 0:
            d = 1
        elif direction.x < 0:
            d = -1
        _ground_state(delta, move_vector, d)
        if abs(velocity.x) > MAX_SPEED:
            velocity.x = sign(velocity.x) * MAX_SPEED
    else:
        _air_state(delta, move_vector)
        if abs(velocity.x) > MAX_SPEED:
            velocity.x = sign(velocity.x) * MAX_SPEED

    if direction:
        _look(DEFAULT_VECTOR.angle_to(direction))
    else:
        look_default()

    if -velocity.y > MAX_JUMP_SPEED:
        velocity.y = -MAX_JUMP_SPEED

    if velocity.y > MAX_FALL_SPEED:
        velocity.y = MAX_FALL_SPEED

    player.move_and_slide(recoil, FLOOR_NORMAL, SLOPE_FRICTION)
    velocity = player.move_and_slide(velocity, FLOOR_NORMAL, SLOPE_FRICTION)
    recoil = Vector2()

    if not player.gun:
        anim.blend2_node_set_amount(AIM_BLEND_NODE, 0)
    else:
        anim.blend2_node_set_amount(AIM_BLEND_NODE, 1)