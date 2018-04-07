#include "minigun_bullet.hpp"

MinigunBullet::MinigunBullet():Bullet() {
    _DAMAGE = 30;
}
MinigunBullet::~MinigunBullet() {}

void MinigunBullet::_init() {
    Bullet::_init();
}

void MinigunBullet::_ready() {
    Bullet::_ready();
}

void MinigunBullet::_collision(Node2D* body) {
    Bullet::_collision(body);
}

void MinigunBullet::_process (const double delta) {
    Bullet::_process (delta);
}

void MinigunBullet::_register_methods() {
    Bullet::_register_methods();
    register_method ("_init",                                   &MinigunBullet::_init);
    register_method ("_ready",                                  &MinigunBullet::_ready);
    register_method ("_process",                                &MinigunBullet::_process);
    register_method ("_collision",                              &MinigunBullet::_collision);

    //register_property<MinigunBullet, double>("main/health",     &MinigunBullet::_health,        double(50));
    register_property<MinigunBullet, double>("main/damage",     &MinigunBullet::_DAMAGE,        double(50));
    register_property<MinigunBullet, double>("main/lifetime",   &MinigunBullet::_LIFE_TIME,     double(4));
    register_property<MinigunBullet, double>("main/gravity",    &MinigunBullet::_GRAVITY,       double(0));
}
