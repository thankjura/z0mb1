#ifndef AK47_BULLET_H
#define AK47_BULLET_H
#include "bullet.hpp"

class AK47Bullet: public Bullet {
    GODOT_CLASS (AK47Bullet, RigidBody2D);

protected:
    void _collision(Node2D* body);

public:
    AK47Bullet();
    ~AK47Bullet();

    void _init();
    void _ready();
    void _process(const double delta);
    void damage(double d);

    static void _register_methods();
};

#endif
