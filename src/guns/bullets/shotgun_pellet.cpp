#include "shotgun_pellet.hpp"

ShotgunPellet::ShotgunPellet() {}
ShotgunPellet::~ShotgunPellet() {}

void ShotgunPellet::_init() {
    Bullet::_init();
    HEALTH = 80;
    DAMAGE = 100;
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

void ShotgunPellet::_process (const float delta) {
    Bullet::_process (delta);
}

int ShotgunPellet::get_damage() {
    return Bullet::get_damage();
}

void ShotgunPellet::_register_methods() {
    register_method ((char *) "_init", &ShotgunPellet::_init);
    register_method ((char *) "_ready", &ShotgunPellet::_ready);
    register_method ((char *) "_process", &ShotgunPellet::_process);
    register_method ((char *) "damage", &ShotgunPellet::damage);
    register_method ((char *) "_collision", &ShotgunPellet::_collision);
    register_method ((char *) "get_damage", &ShotgunPellet::get_damage);
}
