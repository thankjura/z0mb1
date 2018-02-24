extends AnimationTreePlayer

const GROUND_BLEND_NODE = "ground_blend"
const WALK_SCALE_NODE = "walk_scale"
const AIM_SEEK_NODE = "aim"
const AIM_BLEND_NODE = "aim_blend"
const DIE_TRANSITION_NODE = "die_transition"
const HIT_ONESHOT_NODE = "hit_oneshot"
const HIT_TRANSITION_NODE = "hit_transition"
const JUMP_ONESHOT = "jump_oneshot"
const JUMP_SCALE = "jump_scale"

const AIM_SPEED = 6
const DEFAULT_VECTOR = Vector2(0, -1)

enum STATE {
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
var current_aim_angle = -90
var current_state = STATE.IDLE
var last_hit_vector = Vector2()
var aim_enabled = false

func _ready():
    set_active(true)

func _set_state(state_id):
    if current_state != state_id:
        current_state = state_id
        return true
    return false

func walk(scale = 1):
    if scale < 0.1:
        idle()
    else:
        _set_aim(false)
        if _set_state(STATE.WALK):
            blend2_node_set_amount(GROUND_BLEND_NODE, 1)
        timescale_node_set_scale(WALK_SCALE_NODE, scale * 1.2)

func idle():
    _set_aim(false)
    if _set_state(STATE.IDLE):
        blend2_node_set_amount(GROUND_BLEND_NODE, 0)

func aim(aim_angle, delta):
    _set_aim(true)
    current_aim_angle = lerp(current_aim_angle, aim_angle, AIM_SPEED*delta)
    timeseek_node_seek(AIM_SEEK_NODE, abs(current_aim_angle))

func _set_aim(state):
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

func init_jump():
    timescale_node_set_scale(JUMP_SCALE, 2)
    oneshot_node_start(JUMP_ONESHOT)

func pause_jump():
    timescale_node_set_scale(JUMP_SCALE, 0)

func play_jump():
    timescale_node_set_scale(JUMP_SCALE, 3)

func _process(delta):
    if aim_enabled:
        blend2_node_set_amount(AIM_BLEND_NODE, 1)
    else:
        blend2_node_set_amount(AIM_BLEND_NODE, 0)
