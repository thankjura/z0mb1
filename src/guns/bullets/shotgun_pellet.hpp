#ifndef SHOTGUN_PELLET_H
#define SHOTGUN_PELLET_H
#include "bullet.hpp"

class ShotgunPellet: public Bullet {
    GODOT_CLASS (ShotgunPellet, RigidBody2D);

protected:
    void _collision(Variant body);

public:
    ShotgunPellet();
    ~ShotgunPellet();

    void _init();
    void _ready();
    void _process(const double delta);
    void damage(Variant d);

    static void _register_methods();
};

#endif
