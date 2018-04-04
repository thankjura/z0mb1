#include "shotgun_pellet.hpp"

ShotgunPellet::ShotgunPellet() {}
ShotgunPellet::~ShotgunPellet() {}

void ShotgunPellet::_init() {
    Bullet::_init();
}

void ShotgunPellet::_ready() {
    Bullet::_ready();
}

void ShotgunPellet::damage(Variant d) {
    Bullet::damage(d);
}

void ShotgunPellet::_collision(Variant body) {
    Bullet::_collision(body);
}

void ShotgunPellet::_process (const double delta) {
    Bullet::_process (delta);
}

void ShotgunPellet::_register_methods() {
    register_method ((char *) "_init", &ShotgunPellet::_init);
    register_method ((char *) "_ready", &ShotgunPellet::_ready);
    register_method ((char *) "_process", &ShotgunPellet::_process);
    register_method ((char *) "damage", &ShotgunPellet::damage);
    register_method ((char *) "_collision", &ShotgunPellet::_collision);

    register_property<ShotgunPellet, double>    ("main/health", &ShotgunPellet::_health, double(80));
    register_property<ShotgunPellet, double>    ("main/damage", &ShotgunPellet::_DAMAGE, double(100));
    register_property<ShotgunPellet, double>    ("main/lifetime", &ShotgunPellet::_LIFE_TIME, double(4));
    register_property<ShotgunPellet, double>    ("main/gravity", &ShotgunPellet::_GRAVITY, double(0));
}
