#include "enemy.hpp"
#include "../constants.hpp"
#include "../utils/utils.hpp"

Enemy::Enemy() {
    _FLOOR_NORMAL = Vector2(0, -1);
    _velocity = Vector2();
    _recoil = Vector2();
}
Enemy::~Enemy() {}

void Enemy::_init() {}
void Enemy::_ready() {
    set_collision_mask(layers::ENEMY_MASK);
    set_collision_layer(layers::ENEMY_LAYER);
}

bool Enemy::is_back() {
    return ((Node2D*) get_node("base"))->get_scale().x == -1;
}

void Enemy::die() {
    _dead = true;
    set_collision_mask(layers::GROUND_LAYER);
}

void Enemy::damage(const double d, const Vector2 v) {
    _recoil += (v/20);
    if (!_dead) {
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
    
    _velocity.y = lerp(_velocity.y, _MAX_FALL_SPEED, _GRAVITY*delta);
    
    _velocity = move_and_slide(_velocity + _recoil, _FLOOR_NORMAL, false, _SLOPE_FRICTION);
    _velocity -= _recoil;
    Vector2 new_recoil = _recoil.linear_interpolate(Vector2(), 10*delta);
    if (sign(_recoil.x) != sign(new_recoil.x)) {
        new_recoil.x = 0;
    }
    
    if (sign(_recoil.y) != sign(new_recoil.y)) {
        new_recoil.y = 0;
    }
    
    _recoil = new_recoil;
}
