#include "enemy.hpp"
#include "../constants.hpp"
#include "../utils/utils.hpp"

Enemy::Enemy() {
    _FLOOR_NORMAL = Vector2(0, -1);
    _MAX_FALL_SPEED = 800;
    _SLOPE_FRICTION = 10;
    _GRAVITY = 2000;
    _INIT_HEALTH = 100;
    _velocity = Vector2();
    _recoil = Vector2();
}
Enemy::~Enemy() {}

void Enemy::_init() {}
void Enemy::_ready() {
    _health = _INIT_HEALTH;
    set_collision_mask(layers::ENEMY_MASK);
    set_collision_layer(layers::ENEMY_LAYER);
    _player = as<PlayerHenry>(get_tree()->get_current_scene()->get_node("player"));
}

bool Enemy::is_back() {
    return ((Node2D*) get_node("base"))->get_scale().x == -1;
}

void Enemy::die() {
    _dead = true;
    set_collision_mask(layers::GROUND_LAYER);
}

void Enemy::damage(const double d, const Vector2 v) {
    _recoil += Vector2().linear_interpolate(v.normalized(), std::min(d/_INIT_HEALTH, 1.5));
    if (not _dead) {
        _health -= d;
    }
}

void Enemy::_process(const double delta) {
    if (_dead) {
        return;
    }
    
    if (_health <= 0) {
        die();
    }
}

void Enemy::_physics_process(const double delta) {
    if (_dead) {
        _velocity.x = utils::lerp(_velocity.x, 0, delta*20);
    }
    
    _velocity.y += _GRAVITY * delta;
    if (_velocity.y > _MAX_FALL_SPEED) {
        _velocity.y = _MAX_FALL_SPEED;
    }

    _velocity = move_and_slide(_velocity + _recoil, _FLOOR_NORMAL, false, _SLOPE_FRICTION);
    _velocity -= _recoil;
    Vector2 new_recoil = _recoil.linear_interpolate(Vector2(), 10*delta);
    if (utils::sign(_recoil.x) != utils::sign(new_recoil.x)) {
        new_recoil.x = 0;
    }
    if (utils::sign(_recoil.y) != utils::sign(new_recoil.y)) {
        new_recoil.y = 0;
    }
    _recoil = new_recoil;
}
