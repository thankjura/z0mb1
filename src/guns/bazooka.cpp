#include "bazooka.hpp"

Bazooka::Bazooka() {
    _wait_for_reload = 0;
}

Bazooka::~Bazooka() {};

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

    //register_property<Bazooka, Ref<PackedScene>> ("scenes/bullet", &Bazooka::_BULLET, ResourceLoader::get_singleton()->load("res://scenes/guns/bullets/bazooka_rocket.tscn"));
    //register_property<Bazooka, Ref<PackedScene>> ("scenes/entity", &Bazooka::_ENTITY, ResourceLoader::get_singleton()->load("res://scenes/entities/bazooka_entity.tscn"));

    register_property<Bazooka, int>      ("main/speed", &Bazooka::_SPEED, int(30000));
    register_property<Bazooka, double>   ("main/timeout", &Bazooka::_TIMEOUT, double(2.5));
    register_property<Bazooka, double>   ("main/spreading", &Bazooka::_SPREADING, double(0));
    register_property<Bazooka, Vector2>  ("main/recoil", &Bazooka::_RECOIL, Vector2(0,0));
    register_property<Bazooka, Vector2>  ("main/drop_velocity", &Bazooka::_DROP_VELOCITY, Vector2(300, -300));
    register_property<Bazooka, int>      ("main/drop_angular", &Bazooka::_DROP_ANGULAR, int(1));

    register_property<Bazooka, String>   ("player/anim_name", &Bazooka::_AIM_NAME, String("aim_bazooka"));
    register_property<Bazooka, int>      ("player/view_port_shutter", &Bazooka::_VIEWPORT_SHUTTER, int(0));
    register_property<Bazooka, double>   ("player/heavines", &Bazooka::_HEAVINES, double(0.4));

    register_property<Bazooka, int>      ("dead_zone/top", &Bazooka::_ANIM_DEAD_ZONE_TOP, int(0));
    register_property<Bazooka, int>      ("dead_zone/bottom", &Bazooka::_ANIM_DEAD_ZONE_BOTTOM, int(36));

    register_property<Bazooka, Vector2>  ("position/offset", &Bazooka::_OFFSET, Vector2(-24, -40));
    register_property<Bazooka, Vector2>  ("position/climb_offset", &Bazooka::_CLIMB_OFFSET, Vector2(-24, -40));
}
