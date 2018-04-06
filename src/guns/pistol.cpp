#include "pistol.hpp"

Pistol::Pistol():Gun() {
    _AIM_NAME = "aim_pistol";
    
    _ANIM_DEAD_ZONE_TOP = 0;
    _ANIM_DEAD_ZONE_BOTTOM = 40;

    _OFFSET = Vector2(45, -39);
    _CLIMB_OFFSET = Vector2(7, 64);
}

Pistol::~Pistol() {}

void Pistol::_init() {
    Gun::_init();    
}

void Pistol::_ready() {
    Gun::_ready();
    _animation = ((AnimationPlayer*) get_node("animation_player"));
    
    _BULLET = ResourceLoader::get_singleton()->load("res://scenes/guns/bullets/pistol_bullet.tscn");
    _ENTITY = ResourceLoader::get_singleton()->load("res://scenes/entities/pistol_entity.tscn");
    _SHELL = ResourceLoader::get_singleton()->load("res://scenes/guns/shells/pistol_shell.tscn");
}

void Pistol::_muzzle_flash() {
    char anim_name[10];
    sprintf(anim_name, "fire%d", (1 + (rand() % static_cast<int>(2))));
    _animation->play(anim_name, 0);
    _eject_shell();
}


void Pistol::_process(const double delta) {
    Gun::_process(delta);
}

void Pistol::_register_methods() {
    register_method ("_init",                                       &Pistol::_init);
    register_method ("_ready",                                      &Pistol::_ready);
    register_method ("_process",                                    &Pistol::_process);

    register_property<Pistol, double>   ("main/speed",              &Pistol::_SPEED,                   double(70000));
    register_property<Pistol, double>   ("main/timeout",            &Pistol::_TIMEOUT,                 double(0.4));
    register_property<Pistol, double>   ("main/spreading",          &Pistol::_SPREADING,               double(0.01));
    register_property<Pistol, Vector2>  ("main/recoil",             &Pistol::_RECOIL,                  Vector2());
    register_property<Pistol, Vector2>  ("main/drop_velocity",      &Pistol::_DROP_VELOCITY,           Vector2(300, -300));
    register_property<Pistol, double>   ("main/drop_angular",       &Pistol::_DROP_ANGULAR,            double(20));
    register_property<Pistol, Vector2>  ("main/eject_shell_vector", &Pistol::_EJECT_SHELL_VECTOR,      Vector2(0, -200));

    register_property<Pistol, double>   ("player/view_port_shutter",&Pistol::_VIEWPORT_SHUTTER,        double(0));
    register_property<Pistol, double>   ("player/heavines",         &Pistol::_HEAVINES,                double(0));
}
