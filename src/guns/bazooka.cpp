#include "bazooka.hpp"

Bazooka::Bazooka():Gun() {
    _wait_for_reload = 0;
    _AIM_NAME = "aim_bazooka"; 
}

Bazooka::~Bazooka() {}

void Bazooka::_init() {
    Gun::_init();
    _BULLET = ResourceLoader::get_singleton()->load("res://scenes/guns/bullets/bazooka_rocket.tscn");
    _ENTITY = ResourceLoader::get_singleton()->load("res://scenes/entities/bazooka_entity.tscn");
}

void Bazooka::_ready() {
    Gun::_ready();
}

void Bazooka::_reload() {
    get_parent()->get_owner()->call("gun_reload");
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
    register_method ("_init", &Bazooka::_init);
    register_method ("_ready", &Bazooka::_ready);
    register_method ("_process", &Bazooka::_process);

    register_property<Bazooka, double>      ("main/speed", &Bazooka::_SPEED, double(30000));
    register_property<Bazooka, double>   ("main/timeout", &Bazooka::_TIMEOUT, double(2.5));
    register_property<Bazooka, double>   ("main/spreading", &Bazooka::_SPREADING, double(0));
    register_property<Bazooka, Vector2>  ("main/recoil", &Bazooka::_RECOIL, Vector2(0,0));
    register_property<Bazooka, Vector2>  ("main/drop_velocity", &Bazooka::_DROP_VELOCITY, Vector2(300, -300));
    register_property<Bazooka, double>      ("main/drop_angular", &Bazooka::_DROP_ANGULAR, double(1));

    register_property<Bazooka, double>      ("player/view_port_shutter", &Bazooka::_VIEWPORT_SHUTTER, double(0));
    register_property<Bazooka, double>   ("player/heavines", &Bazooka::_HEAVINES, double(0.4));

    register_property<Bazooka, double>      ("dead_zone/top", &Bazooka::_ANIM_DEAD_ZONE_TOP, double(0));
    register_property<Bazooka, double>      ("dead_zone/bottom", &Bazooka::_ANIM_DEAD_ZONE_BOTTOM, double(36));

    register_property<Bazooka, Vector2>  ("position/offset", &Bazooka::_OFFSET, Vector2(-24, -40));
    register_property<Bazooka, Vector2>  ("position/climb_offset", &Bazooka::_CLIMB_OFFSET, Vector2(-24, -40));
}
