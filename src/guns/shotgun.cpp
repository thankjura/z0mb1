#include "shotgun.hpp"

Shotgun::~Shotgun() {}

Shotgun::Shotgun:Gun() {
    _AIM_NAME = "aim_shotgun";
}

void Shotgun::_init() {
    Gun::_init();
    
    _BULLET = ResourceLoader::get_singleton()->load("res://scenes/guns/bullets/shotgun_pellet.tscn");
    _ENTITY = ResourceLoader::get_singleton()->load("res://scenes/entities/shotgun_entity.tscn");
    _SHELL = ResourceLoader::get_singleton()->load("res://scenes/guns/shells/shotgun_shell.tscn");
}

void Shotgun::_ready() {
    Gun::_ready();
    _audio_reload = ((AudioStreamPlayer2D*) get_node("audio_reload"));
    _audio_fire = ((AudioStreamPlayer2D*) get_node("audio_fire"));
    _animation = ((AnimationPlayer*) get_node("anim"));
    _animation->connect("animation_finished", this, "_end_animation");
}

void Shotgun::_end_animation(Variant anim_name) {
    if (anim_name == String("fire")) {
        _player->gun_reload();
        _animation->play("reload", -1, 3);
        _audio_reload->play();
        _fire_stop();
    }
}

void Shotgun::_create_pellet(const Vector2 spawn_point, const Vector2 bullet_velocity) {
    RigidBody2D* p = (RigidBody2D*) _BULLET.ptr()->instance();
    Vector2 v = bullet_velocity.rotated(utils::deg2rad((rand() / static_cast <double> (RAND_MAX))*6-3));
    v.normalized();
    p->rotate(Vector2(1, 0).angle_to(v));
    p->set_axis_velocity(v*_SPEED*(1.2 - ( (rand() / static_cast <double> (RAND_MAX)) *0.4)));
    p->set_global_position(spawn_point);
    _world->add_child(p);
}

void Shotgun::fire(const double delta, const Vector2 velocity) {
    if (_wait_ready > 0) {
        return;
    }
    _wait_ready = _TIMEOUT;

    _audio_fire->play();
    _animation->play("fire", -1, 5);
    Vector2 spawn_point = ((Node2D*) get_node("bullet_spawn"))->get_global_position();
    Vector2 bullet_velocity = (spawn_point - get_global_position()).normalized();
    _recoil(_RECOIL.rotated(bullet_velocity.angle()));
    _shutter_camera();
    for (int i = 0; i < _PELLETS_PER_SHOOT; i++) {
        _create_pellet(spawn_point, bullet_velocity);
    }
}

void Shotgun::_reset_view() {
    _animation->set_current_animation("reload");
    _animation->seek(_animation->get_current_animation_length());
    _animation->stop(false);
    ((Node2D*) get_node("flash"))->set_visible(false);
}

void Shotgun::_process(const double delta) {
    Gun::_process(delta);
}

void Shotgun::_register_methods() {
    register_method ("_init", &Shotgun::_init);
    register_method ("_ready", &Shotgun::_ready);
    register_method ("_process", &Shotgun::_process);
    
    register_method ("_end_animation", &Shotgun::_end_animation);

    register_property<Shotgun, double>   ("main/speed",              &Shotgun::_SPEED, double(90000));
    register_property<Shotgun, double>   ("main/timeout",            &Shotgun::_TIMEOUT, double(1));
    //register_property<Shotgun, double>   ("main/spreading",          &Shotgun::_SPREADING, double(0.01));
    register_property<Shotgun, Vector2>  ("main/recoil",             &Shotgun::_RECOIL, Vector2(-300,0));
    register_property<Shotgun, Vector2>  ("main/drop_velocity",      &Shotgun::_DROP_VELOCITY, Vector2(400, -400));
    register_property<Shotgun, double>   ("main/drop_angular",       &Shotgun::_DROP_ANGULAR, double(1));
    register_property<Shotgun, Vector2>  ("main/eject_shell_vector", &Shotgun::_EJECT_SHELL_VECTOR, Vector2(0, -300));
    register_property<Shotgun, int>      ("main/pelets_per_shoot",   &Shotgun::_PELLETS_PER_SHOOT, int(10));

    register_property<Shotgun, double>   ("player/view_port_shutter",&Shotgun::_VIEWPORT_SHUTTER, double(3));
    register_property<Shotgun, double>   ("player/heavines",         &Shotgun::_HEAVINES, double(0.3));

    register_property<Shotgun, double>   ("dead_zone/top",           &Shotgun::_ANIM_DEAD_ZONE_TOP, double(0));
    register_property<Shotgun, double>   ("dead_zone/bottom",        &Shotgun::_ANIM_DEAD_ZONE_BOTTOM, double(15));

    register_property<Shotgun, Vector2> ("position/offset",          &Shotgun::_OFFSET, Vector2(104, -22));
    register_property<Shotgun, Vector2> ("position/climb_offset",    &Shotgun::_CLIMB_OFFSET, Vector2(3, -25));
}
