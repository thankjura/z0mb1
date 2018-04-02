#ifndef BULLET_H
#define BULLET_H
#include <core/Godot.hpp>
#include <RigidBody2D.hpp>
#include <Particles2D.hpp>
#include <Sprite.hpp>
#include <Light2D.hpp>
#include <CanvasItem.hpp>

#include "../../constants.hpp"

using namespace godot;

class Bullet: public RigidBody2D {
    //GODOT_CLASS (Bullet, RigidBody2D);

protected:
    int _DAMAGE;
    int _HEALTH;
    double _LIFE_TIME;
    double _GRAVITY;

    Sprite* _sprite;

    int _health;
    bool _active;
    bool _decal;
    double _rocket_timeout;

    virtual void _collision(Variant body);
    virtual void _deactivate();

public:
    Bullet();
    virtual ~Bullet();

    void _init();
    void _ready();
    void _process(const double delta);
    virtual void damage(Variant d);
};

#endif
