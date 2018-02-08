extends AnimationTreePlayer

const RUN_SPEED = 300
const GROUND_SCALE_RATE = 1.2
const AIM_SPEED = 5

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
const AIM_SEEK_NODE = "gun_angle"

const SHOTGUN_RELOAD_IN = 0.1
const SHOTGUN_RELOAD_OUT = 0.1

const AIM_SHOTGUN_NAME = "aim_shotgun"

enum STATE {
    GROUND,
    JUMP_UP,
    JUMP_DOWN
}

var current_state = STATE.GROUND

enum AIM {
    aim_pistol,
    aim_ak47,
    aim_shotgun,
    aim_minigun,
    aim_bazooka,
}

var current_aim_anim = null

var current_aim_angle = 90

var reload_in_timeout = 0
var reload_in_time = 1
var reload_out_timeout = 0
var reload_out_time = 1

var player

func _ready():
    player = get_parent()
    set_active(true)

func _set_state(state):
    if current_state != state:
        current_state = state
        return true
    return false

func walk(velocity, delta, direction, MAX_SPEED):
    if sign(velocity) * direction > 0:
        blend2_node_set_amount(WALK_DIRECTION_NODE, 0)
        blend2_node_set_amount(RUN_DIRECTION_NODE, 0)
    else:
        blend2_node_set_amount(WALK_DIRECTION_NODE, 1)
        blend2_node_set_amount(RUN_DIRECTION_NODE, 1)
    if abs(velocity) >= RUN_SPEED:
        blend2_node_set_amount(WALK_BLEND_NODE, 1)
    else:
        blend2_node_set_amount(WALK_BLEND_NODE, 0)

    blend2_node_set_amount(GROUND_BLEND_NODE, abs(velocity / MAX_SPEED))
    timescale_node_set_scale(GROUND_SCALE_NODE, abs(velocity)*delta*GROUND_SCALE_RATE)
    if _set_state(STATE.GROUND):
        transition_node_set_current(STATE_NODE, STATE.GROUND)

func jump(velocity):
    print(velocity)
    if velocity.y > 0 and _set_state(STATE.JUMP_DOWN):
        transition_node_set_current(STATE_NODE, STATE.JUMP_DOWN)
    elif velocity.y < 0 and _set_state(STATE.JUMP_UP):
        transition_node_set_current(STATE_NODE, STATE.JUMP_UP)

func aim(angle, delta):
    current_aim_angle = lerp(current_aim_angle, abs(angle), AIM_SPEED*delta)
    timeseek_node_seek(AIM_SEEK_NODE, abs(angle))

func set_gun():
    player.get_node("base/pelvis/body/sholder_r/forearm_r/hand_r").set_visible(false)
    player.get_node("base/pelvis/body/sholder_l/forearm_l/hand_l").set_visible(false)
    if player.gun.AIM_NAME == "aim_pistol":
        player.get_node("base/pelvis/body/sholder_r/forearm_r/hand_r_pistol").set_visible(true)
        player.get_node("base/pelvis/body/sholder_l/forearm_l/hand_l_pistol").set_visible(true)
    elif player.gun.AIM_NAME == "aim_minigun":
        player.get_node("base/pelvis/body/sholder_r/forearm_r/hand_r_minigun").set_visible(true)
        player.get_node("base/pelvis/body/sholder_l/forearm_l/hand_l_minigun").set_visible(true)
    elif player.gun.AIM_NAME in ["aim_shotgun", "aim_ak47", "aim_bazooka"]:
        player.get_node("base/pelvis/body/sholder_r/forearm_r/hand_r_pistol").set_visible(true)
        player.get_node("base/pelvis/body/sholder_l/forearm_l/hand_l_shotgun").set_visible(true)
    transition_node_set_current(AIM_SWITCH_NODE, AIM[player.gun.AIM_NAME])

func drop_gun():
    player.get_node("base/pelvis/body/sholder_r/forearm_r/hand_r").set_visible(true)
    player.get_node("base/pelvis/body/sholder_l/forearm_l/hand_l").set_visible(true)
    #  For pistol
    player.get_node("base/pelvis/body/sholder_r/forearm_r/hand_r_pistol").set_visible(false)
    player.get_node("base/pelvis/body/sholder_l/forearm_l/hand_l_pistol").set_visible(false)
    #  For minigun
    player.get_node("base/pelvis/body/sholder_r/forearm_r/hand_r_minigun").set_visible(false)
    player.get_node("base/pelvis/body/sholder_l/forearm_l/hand_l_minigun").set_visible(false)
    #  For shotgun / ak47 / bazooka
    player.get_node("base/pelvis/body/sholder_l/forearm_l/hand_l_shotgun").set_visible(false)

    # Reset animations
    oneshot_node_stop(BAZOOKA_RELOAD_NODE)

func gun_reload():
    if player.gun and player.gun.AIM_NAME == AIM_SHOTGUN_NAME:
        _start_gun_reload()
    if player.gun and player.gun.AIM_NAME == "aim_bazooka":
        oneshot_node_start(BAZOOKA_RELOAD_NODE)

func _start_gun_reload():
    if player.gun and player.gun.AIM_NAME == AIM_SHOTGUN_NAME:
        reload_in_timeout = SHOTGUN_RELOAD_IN
        reload_in_time = SHOTGUN_RELOAD_IN

func _stop_gun_reload():
    if player.gun and player.gun.AIM_NAME == AIM_SHOTGUN_NAME:
        reload_out_timeout = SHOTGUN_RELOAD_OUT
        reload_out_time = SHOTGUN_RELOAD_OUT

func _process(delta):
    if reload_in_timeout > 0:
        blend2_node_set_amount(SHOTGUN_RELOAD_NODE, 1-reload_in_timeout/reload_in_time)
        reload_in_timeout -= delta
        if reload_in_timeout <= 0:
            blend2_node_set_amount(SHOTGUN_RELOAD_NODE, 1)
            _stop_gun_reload()

    if reload_out_timeout > 0:
        blend2_node_set_amount(SHOTGUN_RELOAD_NODE, reload_out_timeout/reload_out_time)
        reload_out_timeout -= delta
        if reload_out_timeout <= 0:
            blend2_node_set_amount(SHOTGUN_RELOAD_NODE, 0)

    if not player.gun:
        blend2_node_set_amount(AIM_BLEND_NODE, 0)
    else:
        blend2_node_set_amount(AIM_BLEND_NODE, 1)
