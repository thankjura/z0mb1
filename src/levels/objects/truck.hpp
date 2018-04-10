#ifndef OBJ_TRUCK_H
#define OBJ_TRUCK_H
#include <core/Godot.hpp>
#include <core/Color.hpp>
#include <Node.hpp>
#include <Node2D.hpp>
#include <Sprite.hpp>
#include <Area2D.hpp>
#include <StaticBody2D.hpp>

using namespace godot;

class ObjTruck: public Node2D {
    GODOT_CLASS(ObjTruck, Node2D);
    
private:
    double _FADE_TIME;
    double _CAMERA_ZOOM;

    bool _is_visible;
    double _fade_timeout;

    Sprite* _sprite;

public:    
    ObjTruck();
    virtual ~ObjTruck();

    void _show(const Node* obj);
    void _hide(const Node* obj);

    void _init();
    void _ready();
    void _process(const double delta);
    
    static void _register_methods();    
};

#endif
