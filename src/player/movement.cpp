#include "player.hpp"

Vector2 PlayerHenry::get_velocity() {
    return _velocity;
}

bool PlayerHenry::is_back() {
    return ((Node2D*) get_node("base"))->get_scale().x != 1;
}

void PlayerHenry::_set_ladder(const Area2D* ladder) {
    if (ladder) {
        _is_climb_state = true;
        _climb_ladder_direction = (get_global_position().x < ladder->get_global_position().x) ? 1 : -1;
    } else {
        _is_climb_state = false;
    }
    
    _climb_ladder = ladder;
}

void PlayerHenry::_recalc_mass() {
    if (_gun) {
        _MAX_SPEED = _INIT_MAX_SPEED - _INIT_MAX_SPEED * _gun->get_heavines();
        _MAX_CLIMB_SPEED = _INIT_MAX_CLIMB_SPEED - _INIT_MAX_CLIMB_SPEED * _gun->get_heavines();
        _JUMP_FORCE = _INIT_JUMP_FORCE - _INIT_JUMP_FORCE * pow(_gun->get_heavines(), 2);
        _ACCELERATION = _INIT_ACCELERATION + _ACCELERATION * _gun->get_heavines();
    } else {
        _MAX_SPEED = _INIT_MAX_SPEED;
        _MAX_CLIMB_SPEED = _INIT_MAX_CLIMB_SPEED;
        _JUMP_FORCE = _INIT_JUMP_FORCE;
        _ACCELERATION = _INIT_ACCELERATION;
    }
}

void PlayerHenry::_ground_state(const double delta, const Vector2 m, const double floor_ratio) {
    _is_air_state = false;
    _jump_count = 0;
    _velocity.x = utils::lerp(_velocity.x, m.x * _MAX_SPEED, _ACCELERATION*delta);
    double v = 0;
    if (std::abs(_velocity.x) > 0.1) {
        v = _velocity.length() * utils::sign(_velocity.x);
    }
    
    int direction = is_back() ? -1 : 1;
    if (floor_ratio == floor_ratio) {
        _anim->set_floor_ratio(floor_ratio*2, direction);
    }
    _anim->walk(v, delta, direction, _MAX_SPEED);
}


void PlayerHenry::_climb_state(const double delta, const Vector2 m) {
    _is_air_state = false;
    double movement = 0;
    if (m.y > 0) { // press down
        movement = -std::max(m.x*_climb_ladder_direction, m.y);
    } else if (m.y < 0) { // press up
        movement = -std::min(m.x*_climb_ladder_direction, m.y);
    } else {
        movement = m.x * _climb_ladder_direction;
    }

    if (movement < 0 and is_on_floor()) {
        _is_climb_state = false;
        _ground_state(delta, Vector2(-movement*_climb_ladder_direction, 0));
        return;
    }
    double distance = ((Node2D*) get_node("climb_center"))->get_global_position().y - _climb_ladder->get_global_position().y;
    if (distance < 0 and std::abs(distance) > PlayerAnim::CLIMB_LADDER_BOTTOM_DISTANCE) {
        _is_climb_state = false;
        _jump();
        return;
    }
    
    if (_climb_ladder_direction > 0) {
        _set_player_direction(1);
    } else if (_climb_ladder_direction < 0) {
        _set_player_direction(-1);
    }
    
    _velocity.y = utils::lerp(_velocity.y, -movement * _MAX_CLIMB_SPEED, _ACCELERATION*delta);
    _velocity.x = 0;
    _anim->climb(_velocity, delta, _MAX_CLIMB_SPEED, distance);
}

void PlayerHenry::_air_state(const double delta, const Vector2 m) {
    double movement = m.x * _MAX_SPEED;
    _velocity.x = utils::lerp(_velocity.x + _recoil.x, movement, _AIR_ACCELERATION*delta);

    if (_velocity.y and _is_air_state) {
        _anim->jump(_velocity);
    } else {
        _is_air_state = true;
    }
}

void PlayerHenry::_look(const double rad, const double delta) {
    double deg = utils::rad2deg(rad);
    if (_gun) {
        _anim->aim(deg, delta);
    }
    if (deg > 0 and deg < 180) {
        _set_player_direction(1);
    } else if (deg > -180 and deg < 0) {
        _set_player_direction(-1);
    }
}

void PlayerHenry::_set_player_direction(const int direction) {
    ((Node2D*) get_node("base"))->set_scale(Vector2(direction,1));
    _anim->set_player_direction(direction);
}

void PlayerHenry::_look_default(const double delta) {
    if (_gun) {
        _anim->aim(90, delta);
    }
}

void PlayerHenry::_jump() {
    if (_is_climb_state) {
        _velocity.y -= _JUMP_FORCE * 0.7;
        _velocity.x += _JUMP_FORCE * 0.7 * -_climb_ladder_direction;
        _is_climb_state = false;
    } else if (_jump_count < _MAX_JUMP_COUNT) {
        _jump_count += 1;
        _velocity.y = -_JUMP_FORCE;
    }
}

void PlayerHenry::gun_recoil(const Vector2 recoil_vector) {
    Vector2 new_recoil = recoil_vector;

    if (-new_recoil.y < _GRAVITY) {
        new_recoil.y = 0;
    }
    _recoil += new_recoil;
}
