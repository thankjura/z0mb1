#include "bazooka.hpp"

Bazooka::Bazooka() {
    _wait_for_reload = 0;
}

Bazooka::~Bazooka() {};

void Bazooka::_init() {
    Gun::_init();
}

void Bazooka::_ready() {
    Gun::_ready();
}

void Bazooka::_reload() {
    owner->get_parent()->get_owner()->call("gun_reload");
}

void Bazooka::_process(const float delta) {
    Gun::_process(delta);
    if (_wait_for_reload > 0) {
        _wait_for_reload -= delta;
        if (_wait_for_reload <= 0) {
            _reload();
        }
    }
}

void Bazooka::fire(const float delta, const Vector2 v) {
    Gun::fire(delta, v);
}

void Bazooka::drop() {
    Gun::drop();
}

void Bazooka::default_offset() {
    Gun::default_offset();
}

void Bazooka::climb_offset() {
    Gun::climb_offset();
}

void Bazooka::_register_methods() {
    register_method ((char *) "_init", &Bazooka::_init);
    register_method ((char *) "_ready", &Bazooka::_ready);
    register_method ((char *) "_process", &Bazooka::_process);
    register_method ((char *) "default_offset", &Bazooka::default_offset);
    register_method ((char *) "climb_offset", &Bazooka::climb_offset);
    register_method ((char *) "fire", &Bazooka::fire);
    register_method ((char *) "drop", &Bazooka::drop);

    register_property<Bazooka, Ref<PackedScene>> ((char *) "scenes/bullet", &Bazooka::_BULLET, ResourceLoader::load("res://scenes/guns/bullets/bazooka_rocket.tscn"));
    register_property<Bazooka, Ref<PackedScene>> ((char *) "scenes/entity", &Bazooka::_ENTITY, ResourceLoader::load("res://scenes/entities/bazooka_entity.tscn"));

    register_property<Bazooka, int>     ((char *) "main/speed", &Bazooka::_SPEED, int(30000));
    register_property<Bazooka, float>   ((char *) "main/timeout", &Bazooka::_TIMEOUT, float(2.5));
    register_property<Bazooka, float>   ((char *) "main/spreading", &Bazooka::_SPREADING, float(0));
    register_property<Bazooka, Vector2> ((char *) "main/recoil", &Bazooka::_RECOIL, Vector2(0,0));
    register_property<Bazooka, Vector2> ((char *) "main/drop_velocity", &Bazooka::_DROP_VELOCITY, Vector2(300, -300));
    register_property<Bazooka, int>     ((char *) "main/drop_angular", &Bazooka::_DROP_ANGULAR, int(1));

    register_property<Bazooka, String>  ((char *) "player/anim_name", &Bazooka::_AIM_NAME, String("aim_bazooka"));
    register_property<Bazooka, int>     ((char *) "player/view_port_shutter", &Bazooka::_VIEWPORT_SHUTTER, int(0));
    register_property<Bazooka, float>   ((char *) "player/heavines", &Bazooka::_HEAVINES, float(0.4));

    register_property<Bazooka, int>     ((char *) "dead_zone/top", &Bazooka::_ANIM_DEAD_ZONE_TOP, int(0));
    register_property<Bazooka, int>     ((char *) "dead_zone/bottom", &Bazooka::_ANIM_DEAD_ZONE_BOTTOM, int(36));

    register_property<Bazooka, Vector2> ((char *) "position/offset", &Bazooka::_OFFSET, Vector2(-24, -40));
    register_property<Bazooka, Vector2> ((char *) "position/climb_offset", &Bazooka::_CLIMB_OFFSET, Vector2(-24, -40));
}
