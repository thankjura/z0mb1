#include "minigun.hpp"

Minigun::Minigun():Gun() {
    _AIM_NAME = "aim_minigun";
    _overheat_time = 0.0;
}

Minigun::~Minigun() {}

void Minigun::_init() {
    Gun::_init();
    _BULLET = ResourceLoader::get_singleton()->load("res://scenes/guns/bullets/minigun_bullet.tscn");
    _ENTITY = ResourceLoader::get_singleton()->load("res://scenes/entities/minigun_entity.tscn");
    _SHELL = ResourceLoader::get_singleton()->load("res://scenes/guns/shells/minigun_shell.tscn");
}

void Minigun::_ready() {
    Gun::_ready();
    _anim = (AnimationPlayer*) get_node("animation_player");
    _overheat = (TextureRect*) get_node("body/overheat");
}

void Minigun::_reset_view() {
    ((Node2D*) get_node("body/barrel_idle"))->show();
    ((Node2D*) get_node("body/barrel_run"))->hide();
    ((Node2D*) get_node("flash"))->hide();
}

void Minigun::_muzzle_flash() {
    _eject_shell();
}

void Minigun::_fire_start() {
    _anim->play("fire");
    _player->set_mouth(PlayerHenry::MOUTH_AGGRESIVE);
}

void Minigun::_fire_stop() {
    _anim->stop(true);
    _player->set_mouth();
    _reset_view();
}

void Minigun::_eject_shell() {
    Vector2 v = _EJECT_SHELL_VECTOR * (0.8 + static_cast<double>(rand() / (static_cast<double>(RAND_MAX/0.4))));
    RigidBody2D* s = (RigidBody2D*) _SHELL.ptr()->instance();
    Node2D* shell_gate = (Node2D*) get_node("shell_gate");
    s->set_global_position(shell_gate->get_global_position());
    s->set_z_index(-20);
    double global_rot = shell_gate->get_global_rotation();
    if (std::abs(global_rot) > 1.5707963267948966) {
        v.x = -v.x;
        global_rot = 3.121592653589793 - global_rot;
    }
    s->set_global_rotation(-3.14 + static_cast<double>(rand() / (static_cast<double>(RAND_MAX/6.28))));
    _world->add_child(s);
    Vector2 impulse = v.rotated(global_rot);
    s->apply_impulse(Vector2(), impulse + _player->get_velocity());
}

void Minigun::_process(const double delta) {
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

void Minigun::_register_methods() {
    register_method ("_init", &Minigun::_init);
    register_method ("_ready", &Minigun::_ready);
    register_method ("_process", &Minigun::_process);

    register_property<Minigun, double>     ("main/speed", &Minigun::_SPEED, double(60000));
    register_property<Minigun, double>   ("main/timeout", &Minigun::_TIMEOUT, double(0.1));
    register_property<Minigun, double>   ("main/spreading", &Minigun::_SPREADING, double(0.05));
    register_property<Minigun, Vector2> ("main/recoil", &Minigun::_RECOIL, Vector2(-200,0));
    register_property<Minigun, Vector2> ("main/drop_velocity", &Minigun::_DROP_VELOCITY, Vector2(400, -400));
    register_property<Minigun, double>     ("main/drop_angular", &Minigun::_DROP_ANGULAR, double(1));
    register_property<Minigun, Vector2> ("main/eject_shell_vector", &Minigun::_EJECT_SHELL_VECTOR, Vector2(0, 300));
    register_property<Minigun, double>   ("main/overheat_time", &Minigun::_OVERHEAD_TIMEOUT, double(4));

    register_property<Minigun, double>     ("player/view_port_shutter", &Minigun::_VIEWPORT_SHUTTER, double(10));
    register_property<Minigun, double>   ("player/heavines", &Minigun::_HEAVINES, double(0.6));

    register_property<Minigun, double>     ("dead_zone/top", &Minigun::_ANIM_DEAD_ZONE_TOP, double(16));
    register_property<Minigun, double>     ("dead_zone/bottom", &Minigun::_ANIM_DEAD_ZONE_BOTTOM, double(0));

    register_property<Minigun, Vector2> ("position/offset", &Minigun::_OFFSET, Vector2(125, 55));
    register_property<Minigun, Vector2> ("position/climb_offset", &Minigun::_CLIMB_OFFSET, Vector2(-50, -40));
}
