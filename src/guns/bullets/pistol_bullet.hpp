#ifndef PISTOL_BULLET_H
#define PISTOL_BULLET_H
#include "bullet.hpp"

class PistolBullet: public Bullet {
    GODOT_CLASS (PistolBullet, RigidBody2D);

protected:
    void _collision(Node2D* body);

public:
    PistolBullet();
    ~PistolBullet();

    void _init();
    void _ready();
    void _process(const double delta);

    static void _register_methods();
};

#endif
