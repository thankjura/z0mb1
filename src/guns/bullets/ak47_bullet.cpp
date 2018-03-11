#include "ak47_bullet.hpp"

AK47Bullet::AK47Bullet() {}
AK47Bullet::~AK47Bullet() {}

void AK47Bullet::_init() {
    Bullet::_init();
}

void AK47Bullet::_ready() {
    Bullet::_ready();
}

void AK47Bullet::damage(Variant d) {
    Bullet::damage(d);
}

void AK47Bullet::_collision(Variant body) {
    Bullet::_collision(body);
}

void AK47Bullet::_process (const float delta) {
    Bullet::_process (delta);
}

void AK47Bullet::_register_methods() {
    register_method ((char *) "_init", &AK47Bullet::_init);
    register_method ((char *) "_ready", &AK47Bullet::_ready);
    register_method ((char *) "_process", &AK47Bullet::_process);
    register_method ((char *) "damage", &AK47Bullet::damage);
    register_method ((char *) "_collision", &AK47Bullet::_collision);

    register_property<AK47Bullet, int>      ("main/health", &AK47Bullet::_HEALTH, int(80));
    register_property<AK47Bullet, int>      ("main/damage", &AK47Bullet::_DAMAGE, int(100));
    register_property<AK47Bullet, float>    ("main/lifetime", &AK47Bullet::_LIFE_TIME, float(4));
    register_property<AK47Bullet, float>    ("main/gravity", &AK47Bullet::_GRAVITY, float(0));
}
