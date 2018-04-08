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
    //GODOT_SUBCLASS(Bullet, RigidBody2D);

protected:
    double _DAMAGE;
    double _LIFE_TIME;
    double _GRAVITY;

    Sprite* _sprite;

    double _health;
    double _active;
    double _decal;
    double _rocket_timeout;

    virtual void _collision(Node2D* body);
    virtual void _deactivate();

public:
    Bullet();
    virtual ~Bullet();

    virtual void damage(const double d, const Vector2 = Vector2());
    const double get_damage();
    
    void _init();
    void _ready();
    void _process(const double delta);
    
    //static void _register_methods();
};

#endif
