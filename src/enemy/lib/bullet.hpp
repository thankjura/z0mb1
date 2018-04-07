#ifndef ENEMY_BULLET_H
#define ENEMY_BULLET_H
#include <core/Godot.hpp>
#include <core/Rect2.hpp>
#include <RigidBody2D.hpp>
#include <Area2D.hpp>
#include <Particles2D.hpp>
#include <Sprite.hpp>
#include <SceneTree.hpp>
#include "../../constants.hpp"

using namespace godot;

class EnemyBullet: public RigidBody2D {
    GODOT_CLASS(EnemyBullet, RigidBody2D);
    
private:
    double _LIFE_TIME = 10;
    double _DAMAGE = 30;
    
    Node2D* _world;
    Particles2D* _particles;
    Sprite* _sprite;
    Area2D* _area; 
    
    bool _active;
    bool _decal;
    double _timer;
    
    void _collision(Object* obj);
    void _deactivate();

public:
    EnemyBullet();
    ~EnemyBullet();
    
    void _ready();
    void _init();
    void _process(const double delta);
    
    static void _register_methods();    
};

#endif