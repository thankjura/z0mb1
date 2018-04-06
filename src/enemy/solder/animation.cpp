#include "animation.hpp"
#include "../../utils/utils.hpp"

SolderAnim::SolderAnim() {
    _AIM_SPEED = 6;
    _DEFAULT_VECTOR = Vector2(0, -1);
    
    _current_aim_angle = -90;
    _current_state = ANIM_IDLE;
    _last_hit_vector = Vector2();
    _aim_enabled = false;
}
SolderAnim::~SolderAnim() {}

void SolderAnim::_init() {}

void SolderAnim::_ready() {
    set_active(true);
}

bool SolderAnim::_set_state(AnimState state) {
    if (_current_state != state) {
        _current_state = state;
        return true;
    }
    
    return false;
}

void SolderAnim::walk(const double scale) {
    if (scale < 0.1) {
        idle();
    } else {
        _set_aim(false);
        if (_set_state(ANIM_WALK)) {
            blend2_node_set_amount(_GROUND_BLEND_NODE, 1);
        }
        timescale_node_set_scale(_WALK_SCALE_NODE, scale * 1.2);
    }
}

void SolderAnim::idle() {
    _set_aim(false);
    if (_set_state(ANIM_IDLE)) {
        blend2_node_set_amount(_GROUND_BLEND_NODE, 0);
    }
}

void SolderAnim::aim(const double aim_angle, const double delta) {
    _set_aim(true);
    if (_current_aim_angle != aim_angle) {
        _current_aim_angle = utils::lerp(_current_aim_angle, aim_angle, _AIM_SPEED*delta);
        timeseek_node_seek(_AIM_SEEK_NODE, std::abs(_current_aim_angle));
    }
}

void SolderAnim::_set_aim(bool state) {
    _aim_enabled = state;
}

void SolderAnim::die() {
    if ((((Node2D*) (get_parent()->get_node("base")))->get_scale().x == 1) == (_last_hit_vector.x > 0)) {
        transition_node_set_current(_DIE_TRANSITION_NODE, ON_BACK);
    } else {
        transition_node_set_current(_DIE_TRANSITION_NODE, ON_FACE);
    }
}

void SolderAnim::hit_head(const Vector2 vector) {
    _last_hit_vector = vector;
    if ((((Node2D*) get_parent()->get_node("base"))->get_scale().x == 1) == (vector.x > 0)) {
        transition_node_set_current(_HIT_TRANSITION_NODE, HEAD_BACK);
    } else {
        transition_node_set_current(_HIT_TRANSITION_NODE, HEAD_FACE);
    }
    oneshot_node_start(_HIT_ONESHOT_NODE);
}

void SolderAnim::hit_body(const Vector2 vector) {
    _last_hit_vector = vector;
}

void SolderAnim::init_jump() {
    timescale_node_set_scale(_JUMP_SCALE, 2);
    oneshot_node_start(_JUMP_ONESHOT);
}

void SolderAnim::pause_jump() {
    timescale_node_set_scale(_JUMP_SCALE, 0);
}

void SolderAnim::play_jump() {
    timescale_node_set_scale(_JUMP_SCALE, 3);
}

void SolderAnim::_process(const double delta) {
    if (_aim_enabled) {
        blend2_node_set_amount(_AIM_BLEND_NODE, 1);
    } else {
        blend2_node_set_amount(_AIM_BLEND_NODE, 0);
    }
}

void SolderAnim::_register_methods() {
    register_method("_init",                    &SolderAnim::_init);
    register_method("_ready",                   &SolderAnim::_ready);
    register_method("_process",                 &SolderAnim::_process);
    
    register_property("main/aim_speed",         &SolderAnim::_AIM_SPEED,       double(6));
}
