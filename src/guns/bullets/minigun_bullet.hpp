#ifndef MINIGUN_BULLET_H
#define MINIGUN_BULLET_H
#include "bullet.hpp"

class MinigunBullet: public Bullet {
    GODOT_CLASS (MinigunBullet, RigidBody2D);

protected:
    void _collision(Node2D* body);

public:
    MinigunBullet();
    ~MinigunBullet();

    void _init();
    void _ready();
    void _process(const double delta);
    void damage(double d);

    static void _register_methods();
};

#endif
