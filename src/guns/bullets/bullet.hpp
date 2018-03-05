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

class Bullet: public GodotScript<RigidBody2D> {
    GODOT_CLASS (Bullet);

protected:
    int DAMAGE = 30;
    int HEALTH = 100;
    float LIFE_TIME = 4;
    float GRAVITY = 0;

    Sprite* sprite;

    int health;
    bool active;
    bool decal;
    float rocket_timeout;

    virtual void _collision(Variant body);
    virtual void _deactivate();

public:
    virtual ~Bullet();

    void _init();
    void _ready();
    void _process(const float delta);
    virtual void damage(Variant d);
    virtual int get_damage();
};

#endif
