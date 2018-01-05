const MAX_JUMP_COUNT = 2
const MAX_FALL_SPEED = 800
const MAX_JUMP_SPEED = 800
const GRAVITY = Vector2(0, 2000)

const JUMP_FORCE = 800
const WALK_ACCELERATION = 0.6
const WALK_AIR_ACCELERATION = 0.01
const WALK_MAX_SPEED = 300
const WALK_AIR_MAX_SPEED = 300
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_FRICTION = 20
const DEFAULT_VECTOR = Vector2(0, -1)

const GROUND_BLEND_NODE = "ground_blend"
const GROUND_SCALE_NODE = "ground_scale"
const STATE_NODE = "ground_air_transition"
const AIM_BLEND_NODE = "aim_blend"
const AIM_SWITCH_NODE = "aim_transition"
const SHOTGUN_RELOAD_NODE = "shotgun_reload"

const SHOTGUN_RELOAD_IN = 0.1
const SHOTGUN_RELOAD_OUT = 0.1

const AIM_SHOTGUN_NAME = "aim_shotgun"

enum STATE {
    ground,
    jump_up,
    jump_down
}

enum AIM {
    aim_pistol,
    aim_minigun,
    aim_shotgun
}

var input
var player
var anim

var jump_count = 0
var velocity = Vector2()

var direction = 0

var body_scale

var aim_animation_name = "aim_pistol"
var reload_in_timeout = 0
var reload_in_time = 1
var reload_out_timeout = 0
var reload_out_time = 1
var recoil = Vector2(0, 0)

var air_state = false

func _init(var player, var anim):
    self.player = player
    self.body_scale = player.get_node("body").scale
    self.anim = anim
    self.anim.set_active(true)
    self.input = load("res://scripts/input.gd").new()

func _ground_state(delta, m = Vector2()):
    air_state = false
    var movement = 0
    if m:
        _look(DEFAULT_VECTOR.angle_to(m))
    else:
        look_default()

    if m.x < 0:
        movement = -1
    elif m.x > 0:
        movement = 1
    movement *= WALK_MAX_SPEED
    velocity.x = lerp(velocity.x, movement, WALK_ACCELERATION)
    anim.blend2_node_set_amount(GROUND_BLEND_NODE, abs(velocity.x) / WALK_MAX_SPEED)
    anim.timescale_node_set_scale(GROUND_SCALE_NODE, abs(velocity.x)*delta)
    anim.transition_node_set_current(STATE_NODE, STATE.ground)

func _air_state(delta, m = Vector2()):
    var movement = 0
    if m:
        _look(DEFAULT_VECTOR.angle_to(m))
    else:
        look_default()
    if m.x < 0:
        movement = -1
    elif m.x > 0:
        movement = 1
    movement *= WALK_AIR_MAX_SPEED
    velocity.x = lerp(velocity.x + recoil.x, movement, WALK_AIR_ACCELERATION)

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
        player.get_node("body").set_scale(body_scale)
    elif deg > -180 and deg < 0:
        player.get_node("body").set_scale(Vector2(-body_scale.x, body_scale.y))

func look_default():
    if player.gun:
        anim.timeseek_node_seek("gun_angle", 90)

func jump():
    if jump_count < MAX_JUMP_COUNT:
        jump_count += 1
        velocity.y = -JUMP_FORCE

func set_gun():
    anim.transition_node_set_current(AIM_SWITCH_NODE, AIM[player.gun.AIM_NAME])

func gun_reload():
    if player.gun and player.gun.AIM_NAME == AIM_SHOTGUN_NAME:
        _start_gun_reload()

func gun_recoil(recoil_vector):
    recoil += recoil_vector

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

    if player.is_on_floor():
        jump_count = 0
        _ground_state(delta, move_vector)
        if abs(velocity.x) > WALK_MAX_SPEED:
            velocity.x = sign(velocity.x) * WALK_MAX_SPEED
    else:
        _air_state(delta, move_vector)
        if abs(velocity.x) > WALK_AIR_MAX_SPEED:
            velocity.x = sign(velocity.x) * WALK_AIR_MAX_SPEED

    if -velocity.y > MAX_JUMP_SPEED:
        velocity.y = -MAX_JUMP_SPEED

    if velocity.y > MAX_FALL_SPEED:
        velocity.y = MAX_FALL_SPEED

    velocity.y += player.move_and_slide(recoil, FLOOR_NORMAL, SLOPE_FRICTION).y
    velocity = player.move_and_slide(velocity, FLOOR_NORMAL, SLOPE_FRICTION)
    recoil = Vector2()

    if not player.gun:
        anim.blend2_node_set_amount(AIM_BLEND_NODE, 0)
    else:
        anim.blend2_node_set_amount(AIM_BLEND_NODE, 1)