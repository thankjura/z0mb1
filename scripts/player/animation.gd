extends AnimationTreePlayer

const RUN_SPEED = 300
const GROUND_SCALE_RATE = 1.2
const CLIMB_SCALE_RATE = 3
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
const CLIMB_TRANSITION_NODE = "climb_transition"
const CLIMB_SCALE_NODE = "climb_scale"

const SHOTGUN_RELOAD_IN = 0.1
const SHOTGUN_RELOAD_OUT = 0.1

const AIM_SHOTGUN_NAME = "aim_shotgun"

enum STATE {
    GROUND,
    JUMP_UP,
    JUMP_DOWN,
    CLIMB
}

enum HAND_TYPE {
    DEFAULT,
    CLIMB,
    PISTOL,
    SHOTGUN,
    AK47,
    MINIGUN,
    BAZOOKA
}

var current_state = STATE.GROUND

enum AIM {
    aim_pistol,
    aim_ak47,
    aim_shotgun,
    aim_minigun,
    aim_bazooka,
}

enum CLIMB_DIRECTION {
    UP,
    DOWN
}

var current_aim_anim = null

var current_aim_angle = 90

var reload_in_timeout = 0
var reload_in_time = 1
var reload_out_timeout = 0
var reload_out_time = 1

var player

onready var player_hands = get_tree().get_nodes_in_group("player_hand")

var current_hand_type

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
    _set_hand()

func jump(velocity):
    if velocity.y > 0 and _set_state(STATE.JUMP_DOWN):
        transition_node_set_current(STATE_NODE, STATE.JUMP_DOWN)
    elif velocity.y < 0 and _set_state(STATE.JUMP_UP):
        transition_node_set_current(STATE_NODE, STATE.JUMP_UP)
    _set_hand()

func aim(angle, delta):
    current_aim_angle = lerp(current_aim_angle, abs(angle), AIM_SPEED*delta)
    timeseek_node_seek(AIM_SEEK_NODE, abs(angle))

func climb(velocity, delta, MAX_CLIMB_SPEED):
    if _set_state(STATE.CLIMB):
        transition_node_set_current(STATE_NODE, STATE.CLIMB)
    timescale_node_set_scale(CLIMB_SCALE_NODE, abs(velocity.y) / MAX_CLIMB_SPEED * CLIMB_SCALE_RATE )
    if velocity.y > 0:
        transition_node_set_current(CLIMB_TRANSITION_NODE, CLIMB_DIRECTION.DOWN)
    elif velocity.y < 0:
        transition_node_set_current(CLIMB_TRANSITION_NODE, CLIMB_DIRECTION.UP)
    _set_hand()

func _set_hand_type(hand_type):
    if current_hand_type == hand_type:
        return

    current_hand_type = hand_type

    for h in player_hands:
        h.hide()

    if hand_type == HAND_TYPE.CLIMB:
        player.get_node("base/pelvis/body/sholder_l/forearm_l/hand_l").show()
        player.get_node("base/pelvis/body/sholder_r/forearm_r/hand_r_minigun").show()
    elif hand_type == HAND_TYPE.PISTOL:
        player.get_node("base/pelvis/body/sholder_r/forearm_r/hand_r_pistol").show()
        player.get_node("base/pelvis/body/sholder_l/forearm_l/hand_l_pistol").show()
    elif hand_type == HAND_TYPE.MINIGUN:
        player.get_node("base/pelvis/body/sholder_r/forearm_r/hand_r_minigun").show()
        player.get_node("base/pelvis/body/sholder_l/forearm_l/hand_l_minigun").show()
    elif hand_type in [HAND_TYPE.SHOTGUN, HAND_TYPE.AK47, HAND_TYPE.BAZOOKA]:
        player.get_node("base/pelvis/body/sholder_r/forearm_r/hand_r_pistol").show()
        player.get_node("base/pelvis/body/sholder_l/forearm_l/hand_l_shotgun").show()
    else:
        player.get_node("base/pelvis/body/sholder_r/forearm_r/hand_r").show()
        player.get_node("base/pelvis/body/sholder_l/forearm_l/hand_l").show()

func _set_hand():
    if current_state == STATE.CLIMB:
        _set_hand_type(HAND_TYPE.CLIMB)
    elif player.gun:
        if player.gun.AIM_NAME == "aim_pistol":
            _set_hand_type(HAND_TYPE.PISTOL)
        elif player.gun.AIM_NAME == "aim_minigun":
            _set_hand_type(HAND_TYPE.MINIGUN)
        else:
            _set_hand_type(HAND_TYPE.SHOTGUN)
    else:
        _set_hand_type(HAND_TYPE.DEFAULT)

func set_gun():
    transition_node_set_current(AIM_SWITCH_NODE, AIM[player.gun.AIM_NAME])

func drop_gun():
    _set_hand()

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

    if player.gun and current_state != STATE.CLIMB:
        blend2_node_set_amount(AIM_BLEND_NODE, 1)
    else:
        blend2_node_set_amount(AIM_BLEND_NODE, 0)
