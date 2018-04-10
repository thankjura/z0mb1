#include "bazooka.hpp"
#include <bullets/bazooka_rocket.hpp>

Bazooka::Bazooka():Gun() {
    _wait_for_reload = 0;
    _AIM_NAME = "aim_bazooka";
    _OFFSET = Vector2(-24,-40);
    _CLIMB_OFFSET = Vector2(-24,-40);
    _ANIM_DEAD_ZONE_TOP = 0;
    _ANIM_DEAD_ZONE_BOTTOM = 36;
    
    _ACCELERATION = 10000;
    _RELOAD_TIMEOUT = 0.3;    
}

Bazooka::~Bazooka() {}

void Bazooka::_init() {
    Gun::_init();    
}

void Bazooka::_ready() {
    Gun::_ready();
    _BULLET = ResourceLoader::get_singleton()->load("res://scenes/guns/bullets/bazooka_rocket.tscn");
    _ENTITY = "res://scenes/guns/entities/bazooka_entity.tscn";    
}

void Bazooka::_reload() {
    _player->gun_reload();
}

void Bazooka::fire(const double delta, const Vector2 velocity) {
    if (_wait_ready > 0) {
        return;
    }
    _wait_ready = _TIMEOUT;

    if (not _fired) {
        _fired = true;
        _fire_start();
    }

    BazookaRocket* f = as<BazookaRocket>(_BULLET->instance());
    Vector2 bullet_velocity = _get_bullet_vector();
    double gun_angle = Vector2(1, 0).angle_to(bullet_velocity);
    f->rotate(gun_angle);
    f->set_axis_velocity(bullet_velocity*_SPEED + velocity);
    f->local_dump(velocity);
    f->set_applied_force(bullet_velocity*_ACCELERATION);
    f->set_global_position(_get_bullet_position(gun_angle));
    _world->add_child(f);
    _wait_for_reload = _RELOAD_TIMEOUT;
}

void Bazooka::_process(const double delta) {
    Gun::_process(delta);
    if (_wait_for_reload > 0) {
        _wait_for_reload -= delta;
        if (_wait_for_reload <= 0) {
            _reload();
        }
    }
}

void Bazooka::_register_methods() {
    register_method ("_init",                                           &Bazooka::_init);
    register_method ("_ready",                                          &Bazooka::_ready);
    register_method ("_process",                                        &Bazooka::_process);

    register_property<Bazooka, double>  ("main/speed",                  &Bazooka::_SPEED,                   double(30000));
    register_property<Bazooka, double>  ("main/timeout",                &Bazooka::_TIMEOUT,                 double(2.5));
    register_property<Bazooka, double>  ("main/spreading",              &Bazooka::_SPREADING,               double(0));
    register_property<Bazooka, Vector2> ("main/recoil",                 &Bazooka::_RECOIL,                  Vector2(0,0));
    register_property<Bazooka, Vector2> ("main/drop_velocity",          &Bazooka::_DROP_VELOCITY,           Vector2(300, -300));
    register_property<Bazooka, double>  ("main/drop_angular",           &Bazooka::_DROP_ANGULAR,            double(1));

    register_property<Bazooka, double>  ("player/view_port_shutter",    &Bazooka::_VIEWPORT_SHUTTER,        double(0));
    register_property<Bazooka, double>  ("player/heavines",             &Bazooka::_HEAVINES,                double(0.4));   
}
