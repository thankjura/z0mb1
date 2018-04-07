#ifndef SHOTGUN_PELLET_H
#define SHOTGUN_PELLET_H
#include "bullet.hpp"

class ShotgunPellet: public Bullet {
    GODOT_CLASS (ShotgunPellet, RigidBody2D);

protected:
    void _collision(Node2D* body);

public:
    ShotgunPellet();
    ~ShotgunPellet();

    void _init();
    void _ready();
    void _process(const double delta);

    static void _register_methods();
};

#endif
