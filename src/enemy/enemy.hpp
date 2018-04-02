#ifndef ENEMY_H
#define ENEMY_H
#include <core/Godot.hpp>
#include <core/Vector2.hpp>
#include <KinematicBody2D.hpp>

using namespace godot;

class Enemy: public KinematicBody2D {

protected:
    double _GRAVITY;
    double _MAX_FALL_SPEED;
    double _SLOPE_FRICTION;
    Vector2 _FLOOR_NORMAL;

    bool _dead;
    int _health;

    Vector2 _velocity;
    Vector2 _recoil;

    KinematicBody2D* _player;

public:
    Enemy();
    virtual ~Enemy();

    bool is_back();
    virtual void die();
    virtual void damage(const double d, const Vector2 v);

    void _init();
    void _ready();
    void _process(const double delta);
    void _physics_process(const double delta);
};

#endif
