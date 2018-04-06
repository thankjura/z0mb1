#include "minigun_bullet.hpp"

MinigunBullet::MinigunBullet() {}
MinigunBullet::~MinigunBullet() {}

void MinigunBullet::_init() {
    Bullet::_init();
}

void MinigunBullet::_ready() {
    Bullet::_ready();
}

void MinigunBullet::damage(Variant d) {
    Bullet::damage(d);
}

void MinigunBullet::_collision(Node2D* body) {
    Bullet::_collision(body);
}

void MinigunBullet::_process (const double delta) {
    Bullet::_process (delta);
}

void MinigunBullet::_register_methods() {
    register_method ("_init",                                   &MinigunBullet::_init);
    register_method ("_ready",                                  &MinigunBullet::_ready);
    register_method ("_process",                                &MinigunBullet::_process);
    
    register_method ("damage",                                  &MinigunBullet::damage);
    register_method ("_collision",                              &MinigunBullet::_collision);

    register_property<MinigunBullet, int>   ("main/health",     &MinigunBullet::_health,        int(50));
    register_property<MinigunBullet, int>   ("main/damage",     &MinigunBullet::_DAMAGE,        int(50));
    register_property<MinigunBullet, double>("main/lifetime",   &MinigunBullet::_LIFE_TIME,     double(4));
    register_property<MinigunBullet, double>("main/gravity",    &MinigunBullet::_GRAVITY,       double(0));
}
