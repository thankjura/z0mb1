#ifndef LEVEL_H
#define LEVEL_H
#include <core/Godot.hpp>
#include <Node.hpp>
#include <Camera2D.hpp>
#include <GlobalConstants.hpp>

using namespace godot;

class Level: public Node {

protected:
    Camera2D* _camera;

public:    
    Level();
    virtual ~Level();

    void _init();
    void _ready();    
};

#endif
