#ifndef PISTOL_H
#define PISTOL_H
#include "gun.hpp"
#include <AnimationPlayer.hpp>

class Pistol: public Gun {
    GODOT_CLASS (Pistol, Node2D);

private:
    AnimationPlayer* _animation;
    
protected:
    void _muzzle_flash();    

public:
    Pistol();
    ~Pistol();
    
    void _init();
    void _ready();
    void _process(const double delta);
    static void _register_methods();
};

#endif