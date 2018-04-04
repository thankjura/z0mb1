#include "animation.hpp"

PlayerAnim::PlayerAnim() {
    _AIM["aim_pistol"] = 0;
    _AIM["aim_ak47"] = 1;
    _AIM["aim_shotgun"] = 2;
    _AIM["aim_minigun"] = 3;
    _AIM["aim_bazooka"] = 4;

    _RUN_SPEED = 300;
    _GROUND_SCALE_RATE = 1.2;
    _CLIMB_SCALE_RATE = 2;
    _AIM_SPEED = 5;
    _FLOOR_RATIO_TIME = 0.1;    
    
    _SHOTGUN_RELOAD_IN = 0.1;
    _SHOTGUN_RELOAD_OUT = 0.1;
    
    _current_aim_angle = 90;
    _reload_in_timeout = 0;
    _reload_in_time = 1;
    _reload_out_timeout = 0;
    _reload_out_time = 1;
    
    _floor_ratio = 0;
    _new_floor_ratio = _floor_ratio;
    _floor_ratio_timeout = 0;
    _player_direction = 1;
    _gun = NULL;
}

PlayerAnim::~PlayerAnim() {}

void PlayerAnim::_init() {}

void PlayerAnim::_ready() {
    set_active(true);
    blend3_node_set_amount(_IDLE_CLIMB_BLEND, 0);
    blend3_node_set_amount(_WALK_ANGLE_BLEND, 0);
    blend3_node_set_amount(_WALK_ANGLE_REVERSE_BLEND, 0);
}

bool PlayerAnim::_set_state(State state) {
    if (_current_state != state) {
        _current_state = state;
        return true;
    }
    
    return false;
}

void PlayerAnim::set_floor_ratio(double ratio, int direction) {
    if (std::abs(ratio) < 0.2) {
        ratio = 0;
    }
    
    _player_direction = direction;
    _new_floor_ratio = ratio;
}

void PlayerAnim::walk(const double velocity, const double delta, const int direction, const double max_speed) {
    if (utils::sign(velocity) * direction > 0) {
        transition_node_set_current(_WALK_DIRECTION_NODE, 0);
        transition_node_set_current(_RUN_DIRECTION_NODE, 0);        
    } else {
        transition_node_set_current(_WALK_DIRECTION_NODE, 1);
        transition_node_set_current(_RUN_DIRECTION_NODE, 1);
    }
    
    if (std::abs(velocity) >= _RUN_SPEED && std::abs(_floor_ratio) < 0.1) {
        transition_node_set_current(_WALK_BLEND_NODE, 1);        
    } else {
        transition_node_set_current(_WALK_BLEND_NODE, 0);
    }
    
    blend2_node_set_amount(_GROUND_BLEND_NODE, utils::clamp(std::abs(velocity)/max_speed, 0.0, 1.0));
    timescale_node_set_scale(_GROUND_SCALE_NODE, std::abs(velocity)*delta*_GROUND_SCALE_RATE);
    
    if (_set_state(State::STATE_GROUND)) {
        transition_node_set_current(_STATE_NODE, State::STATE_GROUND);
    }
    
    _set_hand();
}


void PlayerAnim::jump(const Vector2 velocity) {
    if (velocity.y > 0 && _set_state(State::STATE_JUMP_DOWN)) {
        transition_node_set_current(_STATE_NODE, State::STATE_JUMP_DOWN);
    } else if (velocity.y < 0 && _set_state(State::STATE_JUMP_UP)) {
        transition_node_set_current(_STATE_NODE, State::STATE_JUMP_UP);
    }
    
    _set_hand();
}

void PlayerAnim::aim(const double angle, const double delta) {
    _current_aim_angle = utils::lerp(_current_aim_angle, std::abs(angle), _AIM_SPEED*delta);
    timeseek_node_seek(_AIM_SEEK_NODE, std::abs(angle));
}

void PlayerAnim::climb(const Vector2 velocity, const double delta, const double max_climb_speed, double distance) {
    if (_set_state(State::STATE_CLIMB)) {
        transition_node_set_current(_STATE_NODE, State::STATE_CLIMB);
    }
    
    double seek = NAN;
    if (distance > 0 && std::abs(distance) < CLIMB_LADDER_TOP_DISTANCE) {
        seek = 50 - std::abs(distance)/CLIMB_LADDER_TOP_DISTANCE*50;
    } else if (distance < 0) {
        distance = utils::clamp(std::abs(distance), 0.0, CLIMB_LADDER_BOTTOM_DISTANCE);
        seek = 50 + distance/CLIMB_LADDER_BOTTOM_DISTANCE*50;
    }
    
    if (seek == seek) {
        blend2_node_set_amount(_CLIMB_TOP_BLEND, 1);
        timeseek_node_seek(_CLIMB_TOP_SEEK, seek);            
    } else {
        blend2_node_set_amount(_CLIMB_TOP_BLEND, 0);
    }
    
    timescale_node_set_scale(_CLIMB_SCALE_NODE, std::abs(velocity.y) / max_climb_speed * _CLIMB_SCALE_RATE);
    if (velocity.y > 0) {
        transition_node_set_current(_CLIMB_TRANSITION_NODE, ClimbDirection::CD_DOWN);
    } else if (velocity.y < 0) {
        transition_node_set_current(_CLIMB_TRANSITION_NODE, ClimbDirection::CD_UP);
    }
    _set_hand();
}

void PlayerAnim::set_player_direction(const int direction) {
    if (_player_direction != direction) {
        _player_direction = direction;
        _floor_ratio = 0;
    }
}

void PlayerAnim::_set_hand_type(HandType hand_type) {
    if (_current_hand_type == hand_type) {
        return;
    }

    _current_hand_type = hand_type;

    get_tree()->call_group("player_hand", "hide");

    if (hand_type == HandType::HT_CLIMB) {
        get_tree()->call_group("player_hand_climb", "show");
    } else if (hand_type == HandType::HT_PISTOL) {
        get_tree()->call_group("player_hand_pistol", "show");
    } else if (hand_type == HandType::HT_MINIGUN) {
        get_tree()->call_group("player_hand_minigun", "show");
    } else if (hand_type == HandType::HT_SHOTGUN ||
               hand_type == HandType::HT_AK47    ||
               hand_type == HandType::HT_BAZOOKA) {
        get_tree()->call_group("player_hand_shotgun", "show");
    } else {
        get_tree()->call_group("player_hand_default", "show");
    }
}

void PlayerAnim::_set_gun_position() {
    if (_gun) {
        if (_current_state == State::STATE_CLIMB) {
            _gun->climb_offset();
        } else {
            _gun->default_offset();
        }
    }
}

void PlayerAnim::_set_hand() {
    _set_gun_position();
    if (_current_state == State::STATE_CLIMB) {
        _set_hand_type(HandType::HT_CLIMB);
    } else if (_gun) {
        const char* anim_name = _gun->get_anim_name();
        if (anim_name == _AIM_PISTOL_NAME) {
            _set_hand_type(HandType::HT_PISTOL);
        } else if (anim_name == _AIM_MINIGUN_NAME) {
            _set_hand_type(HandType::HT_MINIGUN);
        } else {
            _set_hand_type(HandType::HT_SHOTGUN);
        }
    } else {
        _set_hand_type(HandType::HT_DEFAULT);
    }
}

void PlayerAnim::set_gun(Gun* gun) {
    _gun = gun;
    std::string name = _gun->get_anim_name();    
    int x = _AIM[name];
    transition_node_set_current(_AIM_SWITCH_NODE, x);
}

void PlayerAnim::drop_gun() {
    return;
    _set_hand();

    // Reset animations
    oneshot_node_stop(_BAZOOKA_RELOAD_NODE);
}

void PlayerAnim::gun_reload() {
    if (_gun) {
        const char* anim_name = _gun->get_anim_name();
        if (anim_name == _AIM_SHOTGUN_NAME) {
            _start_gun_reload();
        } else if (anim_name == _AIM_BAZOOKA_NAME) {
            oneshot_node_start(_BAZOOKA_RELOAD_NODE);
        }
    }
}

void PlayerAnim::_start_gun_reload() {
    if (_gun && _gun->get_anim_name() == _AIM_SHOTGUN_NAME) {
        _reload_in_timeout = _SHOTGUN_RELOAD_IN;
        _reload_in_time = _SHOTGUN_RELOAD_IN;
    }
}

void PlayerAnim::_stop_gun_reload() {
    if (_gun && _gun->get_anim_name() == _AIM_SHOTGUN_NAME) {
        _reload_out_timeout = _SHOTGUN_RELOAD_OUT;
        _reload_out_time = _SHOTGUN_RELOAD_OUT;
    }
}

void PlayerAnim::_process(const double delta) {
    if (_reload_in_timeout > 0) {
        blend2_node_set_amount(_SHOTGUN_RELOAD_NODE, 1-_reload_in_timeout/_reload_in_time);
        _reload_in_timeout -= delta;
        if (_reload_in_timeout <= 0) {
            blend2_node_set_amount(_SHOTGUN_RELOAD_NODE, 1);
            _stop_gun_reload();
        }
    }
    
    if (_reload_out_timeout > 0) {
        blend2_node_set_amount(_SHOTGUN_RELOAD_NODE, _reload_out_timeout/_reload_out_time);
        _reload_out_timeout -= delta;
        if (_reload_out_timeout <= 0) {
            blend2_node_set_amount(_SHOTGUN_RELOAD_NODE, 0);
        }
    }
    
    if (_floor_ratio != _new_floor_ratio) {
        _floor_ratio_timeout -= delta;
        if (_floor_ratio_timeout <= 0) {
            _floor_ratio = _new_floor_ratio;
        } else {
            _floor_ratio += ((_new_floor_ratio - _floor_ratio)/_FLOOR_RATIO_TIME)*delta;
        }
        
        _floor_ratio = utils::clamp(_floor_ratio, -1.0, 1.0);
        double r = -_floor_ratio * _player_direction;
        blend3_node_set_amount(_WALK_ANGLE_BLEND, r);
        blend3_node_set_amount(_WALK_ANGLE_REVERSE_BLEND, r);
        blend3_node_set_amount(_IDLE_CLIMB_BLEND, r);
    }
    
    if (_gun && _current_state != State::STATE_CLIMB) {
        blend2_node_set_amount(_AIM_BLEND_NODE, 1);
    } else {
        blend2_node_set_amount(_AIM_BLEND_NODE, 0);
    }
}

void PlayerAnim::_register_methods() {
    register_method ("_init",                   &PlayerAnim::_init);
    register_method ("_ready",                  &PlayerAnim::_ready);
    register_method ("_process",                &PlayerAnim::_process);
}
