#include "pistol_bullet.hpp"

PistolBullet::PistolBullet() {}
PistolBullet::~PistolBullet() {}

void PistolBullet::_init() {
    Bullet::_init();
}

void PistolBullet::_ready() {
    Bullet::_ready();
}

void PistolBullet::damage(Variant d) {
    Bullet::damage(d);
}

void PistolBullet::_collision(Node2D* body) {
    Bullet::_collision(body);
}

void PistolBullet::_process (const double delta) {
    Bullet::_process (delta);
}

void PistolBullet::_register_methods() {
    register_method("_init",                                    &PistolBullet::_init);
    register_method("_ready",                                   &PistolBullet::_ready);
    register_method("_process",                                 &PistolBullet::_process);
    register_method("damage",                                   &PistolBullet::damage);
    register_method("_collision",                               &PistolBullet::_collision);

    register_property<PistolBullet, int>    ("main/health",     &PistolBullet::_health,             int(100));
    register_property<PistolBullet, int>    ("main/damage",     &PistolBullet::_DAMAGE,             int(100));
    register_property<PistolBullet, double> ("main/lifetime",   &PistolBullet::_LIFE_TIME,          double(4));
    register_property<PistolBullet, double> ("main/gravity",    &PistolBullet::_GRAVITY,            double(0));
}
