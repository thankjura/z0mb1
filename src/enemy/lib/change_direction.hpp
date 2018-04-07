#ifndef ENEMY_CHANGE_DIRECTION_H
#define ENEMY_CHANGE_DIRECTION_H
#include <core/Godot.hpp>
#include <core/Array.hpp>
#include <Area2D.hpp>
#include "../../constants.hpp"

using namespace godot;

class EnemyChangeDirection: public Area2D {
    GODOT_CLASS(EnemyChangeDirection, Area2D);
    
private:
    int _DIRECTION;
    double _TIMEOUT;
    
    Array _objects;
    void _collision(Object* body);
    void _collision_end(Object* body);

public:
    EnemyChangeDirection();
    ~EnemyChangeDirection();
    
    void _init();
    void _ready();    
    
    static void _register_methods();    
};

#endif