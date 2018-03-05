#include "minigun_bullet.hpp"

MinigunBullet::MinigunBullet() {}
MinigunBullet::~MinigunBullet() {}

void MinigunBullet::_init() {
    Bullet::_init();
    DAMAGE = 50;
    HEALTH = 50;
}

void MinigunBullet::_ready() {
    Bullet::_ready();
}

void MinigunBullet::damage(Variant d) {
    Bullet::damage(d);
}

void MinigunBullet::_collision(Variant body) {
    Bullet::_collision(body);
}

void MinigunBullet::_process (const float delta) {
    Bullet::_process (delta);
}

int MinigunBullet::get_damage() {
    return Bullet::get_damage();
}

void MinigunBullet::_register_methods() {
    register_method ((char *) "_init", &MinigunBullet::_init);
    register_method ((char *) "_ready", &MinigunBullet::_ready);
    register_method ((char *) "_process", &MinigunBullet::_process);
    register_method ((char *) "damage", &MinigunBullet::damage);
    register_method ((char *) "_collision", &MinigunBullet::_collision);
    register_method ((char *) "get_damage", &MinigunBullet::get_damage);
}
