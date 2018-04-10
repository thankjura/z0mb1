#ifndef GUN_ENTITY_H
#define GUN_ENTITY_H
#include <core/Godot.hpp>
#include <Area2D.hpp>
#include <RigidBody2D.hpp>
#include <PackedScene.hpp>
#include <ResourceLoader.hpp>
#include "../constants.hpp"

using namespace godot;

class GunEntity: public RigidBody2D {
    GODOT_CLASS (GunEntity, RigidBody2D);

private:
    double _TIMEOUT;
    double _wait_time;
    
    Area2D* _area;
    
    String _GUN;

    void _collision(Object* obj);

public:    
    GunEntity();
    ~GunEntity();

    void _init();
    void _ready();    
    void _process(const double delta);
    
    static void _register_methods();
};

#endif
