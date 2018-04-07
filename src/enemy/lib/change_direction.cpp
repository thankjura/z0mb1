#include "change_direction.hpp"

EnemyChangeDirection::EnemyChangeDirection() {
    _DIRECTION = -1;
    _TIMEOUT = 5;
    _objects = Array();
}
EnemyChangeDirection::~EnemyChangeDirection() {}

void EnemyChangeDirection::_init() {}

void EnemyChangeDirection::_ready() {
    set_collision_mask(layers::ENEMY_LAYER);
    set_collision_layer(0);
    connect("body_entered", this, "_collision");
    connect("body_exited", this, "_collision_end");
}

void EnemyChangeDirection::_collision_end(Object* body) {
    if (_objects.has(body)) {
        _objects.erase(body);
    }
}

void EnemyChangeDirection::_collision(Object* body) {
    if (body->has_method("change_direction") and not _objects.has(body)) {
        _objects.append(body);
        body->call("change_direction", Array::make(_TIMEOUT, _DIRECTION));
    }
}

void EnemyChangeDirection::_register_methods() {
     register_method(                                "_init",           &EnemyChangeDirection::_init);
     register_method(                                "_ready",          &EnemyChangeDirection::_ready);

     register_property<EnemyChangeDirection, double>("main/timeout",    &EnemyChangeDirection::_TIMEOUT,        double(10));
     register_property<EnemyChangeDirection, int>   ("main/direction",  &EnemyChangeDirection::_DIRECTION,      int(-1));
}
