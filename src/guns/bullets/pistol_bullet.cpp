#include "pistol_bullet.hpp"

PistolBullet::PistolBullet() {}
PistolBullet::~PistolBullet() {}

void PistolBullet::_init() {
    Bullet::_init();
    DAMAGE = 100;
}

void PistolBullet::_ready() {
    Bullet::_ready();
}

void PistolBullet::damage(Variant d) {
    Bullet::damage(d);
}

void PistolBullet::_collision(Variant body) {
    Bullet::_collision(body);
}

void PistolBullet::_process (const float delta) {
    Bullet::_process (delta);
}

int PistolBullet::get_damage() {
    return Bullet::get_damage();
}

void PistolBullet::_register_methods() {
    register_method ((char *) "_init", &PistolBullet::_init);
    register_method ((char *) "_ready", &PistolBullet::_ready);
    register_method ((char *) "_process", &PistolBullet::_process);
    register_method ((char *) "damage", &PistolBullet::damage);
    register_method ((char *) "_collision", &PistolBullet::_collision);
    register_method ((char *) "get_damage", &PistolBullet::get_damage);
}
