#include "ak47.hpp"

AK47Gun::AK47Gun() {
    _overheat_time = 0.0;
}

AK47Gun::~AK47Gun() {};

void AK47Gun::_init() {
    Gun::_init();
    _BULLET = ResourceLoader::get_singleton()->load("res://scenes/guns/bullets/ak47_bullet.tscn");
    _ENTITY = ResourceLoader::get_singleton()->load("res://scenes/entities/ak47_entity.tscn");
    _SHELL = ResourceLoader::get_singleton()->load("res://scenes/guns/shells/ak47_shell.tscn");
}

void AK47Gun::_ready() {
    Gun::_ready();
    _overheat = (TextureRect*) get_node("body/overheat");
}

void AK47Gun::_muzzle_flash() {
    char anim_name[10];
    sprintf(anim_name, "fire%d", (1 + (rand() % static_cast<int>(4))));
    ((AnimationPlayer*) get_node("animation_player"))->play(anim_name, 0);
    _eject_shell();
}

void AK47Gun::_fire_start() {
    _player->set_mouth(PlayerHenry::MOUTH_AGGRESIVE);
}

void AK47Gun::_fire_stop() {
    _player->set_mouth();
}

Vector2 AK47Gun::_get_bullet_velocity(const Vector2 bullet_velocity, const Vector2 player_velocity) {
    return (bullet_velocity * _SPEED) + player_velocity;
}

void AK47Gun::_process(const double delta) {
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

    double c = _overheat_time / _OVERHEAD_TIMEOUT;
    _overheat->set_modulate(Color(c,c,c));
}

void AK47Gun::_register_methods() {
    register_method ("_init", &AK47Gun::_init);
    register_method ("_ready", &AK47Gun::_ready);
    register_method ("_process", &AK47Gun::_process);
    //register_property<AK47Gun, Ref<PackedScene>> ((char*) "scenes/bullet", &AK47Gun::_BULLET, ResourceLoader::get_singleton()->load("res://scenes/guns/bullets/ak47_bullet.tscn"));    //register_property<AK47Gun, Ref<PackedScene>> ("scenes/entity", &AK47Gun::_ENTITY, ResourceLoader::get_singleton()->load("res://scenes/entities/ak47_entity.tscn"));
    //register_property<AK47Gun, Ref<PackedScene>> ("scenes/shell", &AK47Gun::_SHELL, ResourceLoader::get_singleton()->load("res://scenes/guns/shells/ak47_shell.tscn"));

    register_property<AK47Gun, int>     ("main/speed", &AK47Gun::_SPEED, int(60000));
    register_property<AK47Gun, double>   ("main/timeout", &AK47Gun::_TIMEOUT, double(0.1));
    register_property<AK47Gun, double>   ("main/spreading", &AK47Gun::_SPREADING, double(0.05));
    register_property<AK47Gun, Vector2> ("main/recoil", &AK47Gun::_RECOIL, Vector2(-150,0));
    register_property<AK47Gun, Vector2> ("main/drop_velocity", &AK47Gun::_DROP_VELOCITY, Vector2(400, -400));
    register_property<AK47Gun, int>     ("main/drop_angular", &AK47Gun::_DROP_ANGULAR, int(10));
    register_property<AK47Gun, Vector2> ("main/eject_shell_vector", &AK47Gun::_EJECT_SHELL_VECTOR, Vector2(-100, -300));
    register_property<AK47Gun, double>   ("main/overheat_time", &AK47Gun::_OVERHEAD_TIMEOUT, double(3));

    register_property<AK47Gun, String>  ("player/anim_name", &AK47Gun::_AIM_NAME, String("aim_ak47"));
    register_property<AK47Gun, int>     ("player/view_port_shutter", &AK47Gun::_VIEWPORT_SHUTTER, int(0));
    register_property<AK47Gun, double>   ("player/heavines", &AK47Gun::_HEAVINES, double(0.3));

    register_property<AK47Gun, int>     ("dead_zone/top", &AK47Gun::_ANIM_DEAD_ZONE_TOP, int(0));
    register_property<AK47Gun, int>     ("dead_zone/bottom", &AK47Gun::_ANIM_DEAD_ZONE_BOTTOM, int(10));

    register_property<AK47Gun, Vector2> ("position/offset", &AK47Gun::_OFFSET, Vector2(87, -48));
    register_property<AK47Gun, Vector2> ("position/climb_offset", &AK47Gun::_CLIMB_OFFSET, Vector2(10, -18));
}
