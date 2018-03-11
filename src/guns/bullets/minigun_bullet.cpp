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

void MinigunBullet::_collision(Variant body) {
    Bullet::_collision(body);
}

void MinigunBullet::_process (const float delta) {
    Bullet::_process (delta);
}

void MinigunBullet::_register_methods() {
    register_method ((char *) "_init", &MinigunBullet::_init);
    register_method ((char *) "_ready", &MinigunBullet::_ready);
    register_method ((char *) "_process", &MinigunBullet::_process);
    register_method ((char *) "damage", &MinigunBullet::damage);
    register_method ((char *) "_collision", &MinigunBullet::_collision);

    register_property<MinigunBullet, int>      ("main/health", &MinigunBullet::_HEALTH, int(50));
    register_property<MinigunBullet, int>      ("main/damage", &MinigunBullet::_DAMAGE, int(50));
    register_property<MinigunBullet, float>    ("main/lifetime", &MinigunBullet::_LIFE_TIME, float(4));
    register_property<MinigunBullet, float>    ("main/gravity", &MinigunBullet::_GRAVITY, float(0));
}
