extends AnimationTreePlayer

const GROUND_BLEND_NODE = "ground_blend"
const WALK_SCALE_NODE = "walk_scale"
const AIM_SEEK_NODE = "aim"
const AIM_BLEND_NODE = "aim_blend"
const DIE_TRANSITION_NODE = "die_transition"
const HIT_ONESHOT_NODE = "hit_oneshot"
const HIT_TRANSITION_NODE = "hit_transition"

const AIM_SPEED = 6
const DEFAULT_VECTOR = Vector2(0, -1)

# timeouts consts
const SET_AIM_TIME = 0.3

enum ACTIONS {
    IDLE,
    WALK,
    DIE,
    REBOUND
}

enum DIE_ANIMS {
    NONE,
    ON_FACE,
    ON_BACK
}

enum HIT_ANIMS {
    HEAD_BACK,
    HEAD_FACE
}
var current_aim_angle = 90
var current_action = ACTIONS.IDLE
var last_hit_vector = Vector2()
var aim_enabled = false

# timeouts
var set_aim_timeout = 0

func _ready():
    set_active(true)

func _set_action(action_id):
    if current_action != action_id:
        current_action = action_id
        return true
    return false

func walk(scale = 1):
    if not scale:
        idle()
    else:
        _set_aim(false)
        if _set_action(ACTIONS.WALK):
            blend2_node_set_amount(GROUND_BLEND_NODE, 1)
        timescale_node_set_scale(WALK_SCALE_NODE, scale)

func idle():
    _set_aim(false)
    if _set_action(ACTIONS.IDLE):
        blend2_node_set_amount(GROUND_BLEND_NODE, 0)

func aim(aim_angle, delta):
    _set_aim(true)
    current_aim_angle = lerp(current_aim_angle, aim_angle, AIM_SPEED*delta)
    timeseek_node_seek(AIM_SEEK_NODE, abs(current_aim_angle))
    return current_aim_angle

func _set_aim(state):
    if state and not aim_enabled:
        set_aim_timeout = SET_AIM_TIME
    elif not state and aim_enabled:
        set_aim_timeout = SET_AIM_TIME - set_aim_timeout
    aim_enabled = state

func die():
    if (get_parent().get_node("base").scale.x == 1) == (last_hit_vector.x > 0):
        transition_node_set_current(DIE_TRANSITION_NODE, DIE_ANIMS.ON_BACK)
    else:
        transition_node_set_current(DIE_TRANSITION_NODE, DIE_ANIMS.ON_FACE)

func hit_head(vector):
    last_hit_vector = vector
    if (get_parent().get_node("base").scale.x == 1) == (vector.x > 0):
        transition_node_set_current(HIT_TRANSITION_NODE, HIT_ANIMS.HEAD_BACK)
    else:
        transition_node_set_current(HIT_TRANSITION_NODE, HIT_ANIMS.HEAD_FACE)
    oneshot_node_start(HIT_ONESHOT_NODE)

func hit_body(vector):
    last_hit_vector = vector

func _process(delta):
    if set_aim_timeout > 0:
        set_aim_timeout -= delta
        if set_aim_timeout < 0:
            set_aim_timeout = 0
        if aim_enabled:
            blend2_node_set_amount(AIM_BLEND_NODE, (set_aim_timeout/SET_AIM_TIME))
        else:
            blend2_node_set_amount(AIM_BLEND_NODE, (1 - set_aim_timeout/SET_AIM_TIME))
    else:
        if aim_enabled:
            blend2_node_set_amount(AIM_BLEND_NODE, 1)
        else:
            blend2_node_set_amount(AIM_BLEND_NODE, 0)
