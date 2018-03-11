#include "ak47.hpp"

AK47Gun::AK47Gun() {
    _overheat_time = 0.0;
}

AK47Gun::~AK47Gun() {};

void AK47Gun::_init() {
    Gun::_init();
}

void AK47Gun::_ready() {
    Gun::_ready();
}

void AK47Gun::_muzzle_flash() {
    char anim_name[10];
    sprintf(anim_name, "fire%d", (1 + (rand() % static_cast<int>(4))));
    ((AnimationPlayer*) owner->get_node("animation_player"))->play(anim_name, 0);
    _eject_shell();
}

void AK47Gun::_fire_start() {
    //TODO: implements player
    //player->call("set_mouth", player.MOUTH_AGGRESIVE)
}

void AK47Gun::_fire_stop() {
    ((AnimationPlayer*) owner->get_node("animation_player"))->play("stop", 0.2);
    //TODO: implements player
    //player->call("set_mouth", player.MOUTH_AGGRESIVE)
}

Vector2 AK47Gun::_get_bullet_velocity(const Vector2 bullet_velocity, const Vector2 player_velocity) {
    return (bullet_velocity * _SPEED) + player_velocity;
}

void AK47Gun::_process(const float delta) {
    Gun::_process(delta);

    if (_fired) {
        if (_overheat_time < _OVERHEAD_TIMEOUT) {
            _overheat_time += delta;

            if (_overheat_time > _OVERHEAD_TIMEOUT) {
                _overheat_time = _OVERHEAD_TIMEOUT;
            }
        }
    } else {
        if (_overheat_time > 0) {
            _overheat_time -= delta;
            if (_overheat_time < 0) {
                _overheat_time = 0;
            }
        }
    }

    float c = _overheat_time / _OVERHEAD_TIMEOUT;
    ((TextureRect*)owner->get_node("body/overheat"))->set_modulate(Color(c,c,c));
}

void AK47Gun::fire(const float delta, const godot::Vector2 v) {
    Gun::fire(delta, v);
}

void AK47Gun::drop() {
    Gun::drop();
}

void AK47Gun::default_offset() {
    Gun::default_offset();
}

void AK47Gun::climb_offset() {
    Gun::climb_offset();
}

void AK47Gun::_register_methods() {
    register_method ((char *) "_init", &AK47Gun::_init);
    register_method ((char *) "_ready", &AK47Gun::_ready);
    register_method ((char *) "_process", &AK47Gun::_process);
    register_method ((char *) "default_offset", &AK47Gun::default_offset);
    register_method ((char *) "climb_offset", &AK47Gun::climb_offset);
    register_method ((char *) "fire", &AK47Gun::fire);
    register_method ((char *) "drop", &AK47Gun::drop);

    register_property<AK47Gun, Ref<PackedScene>> ((char *) "scenes/bullet", &AK47Gun::_BULLET, ResourceLoader::load("res://scenes/guns/bullets/ak47_bullet.tscn"));
    register_property<AK47Gun, Ref<PackedScene>> ((char *) "scenes/entity", &AK47Gun::_ENTITY, ResourceLoader::load("res://scenes/entities/ak47_entity.tscn"));
    register_property<AK47Gun, Ref<PackedScene>> ((char *) "scenes/shell", &AK47Gun::_SHELL, ResourceLoader::load("res://scenes/guns/shells/ak47_shell.tscn"));

    register_property<AK47Gun, int>     ((char *) "main/speed", &AK47Gun::_SPEED, int(60000));
    register_property<AK47Gun, float>   ((char *) "main/timeout", &AK47Gun::_TIMEOUT, float(0.1));
    register_property<AK47Gun, float>   ((char *) "main/spreading", &AK47Gun::_SPREADING, float(0.05));
    register_property<AK47Gun, Vector2> ((char *) "main/recoil", &AK47Gun::_RECOIL, Vector2(-150,0));
    register_property<AK47Gun, Vector2> ((char *) "main/drop_velocity", &AK47Gun::_DROP_VELOCITY, Vector2(400, -400));
    register_property<AK47Gun, int>     ((char *) "main/drop_angular", &AK47Gun::_DROP_ANGULAR, int(10));
    register_property<AK47Gun, Vector2> ((char *) "main/eject_shell_vector", &AK47Gun::_EJECT_SHELL_VECTOR, Vector2(-100, -300));

    register_property<AK47Gun, String>  ((char *) "player/anim_name", &AK47Gun::_AIM_NAME, String("aim_ak47"));
    register_property<AK47Gun, int>     ((char *) "player/view_port_shutter", &AK47Gun::_VIEWPORT_SHUTTER, int(0));
    register_property<AK47Gun, float>   ((char *) "player/heavines", &AK47Gun::_HEAVINES, float(0.3));

    register_property<AK47Gun, int>     ((char *) "dead_zone/top", &AK47Gun::_ANIM_DEAD_ZONE_TOP, int(0));
    register_property<AK47Gun, int>     ((char *) "dead_zone/bottom", &AK47Gun::_ANIM_DEAD_ZONE_BOTTOM, int(10));

    register_property<AK47Gun, Vector2> ((char *) "position/offset", &AK47Gun::_OFFSET, Vector2(87, -48));
    register_property<AK47Gun, Vector2> ((char *) "position/climb_offset", &AK47Gun::_CLIMB_OFFSET, Vector2(10, -18));
}
