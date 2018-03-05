#include "ak47_bullet.hpp"

AK47Bullet::AK47Bullet() {}
AK47Bullet::~AK47Bullet() {}

void AK47Bullet::_init() {
    Bullet::_init();
    HEALTH = 80;
    DAMAGE = 100;
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

int AK47Bullet::get_damage() {
    return Bullet::get_damage();
}

void AK47Bullet::_register_methods() {
    register_method ((char *) "_init", &AK47Bullet::_init);
    register_method ((char *) "_ready", &AK47Bullet::_ready);
    register_method ((char *) "_process", &AK47Bullet::_process);
    register_method ((char *) "damage", &AK47Bullet::damage);
    register_method ((char *) "_collision", &AK47Bullet::_collision);
    register_method ((char *) "get_damage", &AK47Bullet::get_damage);
}
