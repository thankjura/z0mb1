#include "ak47_bullet.hpp"

AK47Bullet::AK47Bullet():Bullet() {}
AK47Bullet::~AK47Bullet() {}

void AK47Bullet::_init() {
    Bullet::_init();
}

void AK47Bullet::_ready() {
    Bullet::_ready();
}

void AK47Bullet::_collision(Node2D* body) {
    Bullet::_collision(body);
}

void AK47Bullet::_process(const double delta) {
    Bullet::_process (delta);
}

const double AK47Bullet::get_damage() {
    return Bullet::get_damage();
}

void AK47Bullet::_register_methods() {
    register_method ("_init",                                &AK47Bullet::_init);
    register_method ("_ready",                               &AK47Bullet::_ready);
    register_method ("_process",                             &AK47Bullet::_process);
    register_method ("_collision",                           &AK47Bullet::_collision);
    register_method ("get_damage",                           &AK47Bullet::get_damage);

    register_property<AK47Bullet, double>("main/health",     &AK47Bullet::_health,          double(80));
    register_property<AK47Bullet, double>("main/damage",     &AK47Bullet::_DAMAGE,          double(10));
    register_property<AK47Bullet, double>("main/lifetime",   &AK47Bullet::_LIFE_TIME,       double(4));
    register_property<AK47Bullet, double>("main/gravity",    &AK47Bullet::_GRAVITY,         double(0));
}
