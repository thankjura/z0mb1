#ifndef MINIGUN_H
#define MINIGUN_H
#include "gun.hpp"
#include <AnimationPlayer.hpp>
#include <TextureRect.hpp>
#include <core/Color.hpp>

class Minigun: public Gun {
    GODOT_CLASS (Minigun, Node2D);

private:
    double _OVERHEAD_TIMEOUT;
    double _overheat_time;
    TextureRect* _overheat;

    AnimationPlayer* _anim;

    void _reset_view();

protected:
    void _muzzle_flash();
    void _fire_start();
    void _fire_stop();
    void _eject_shell();

public:
    Minigun();
    ~Minigun();

    void _init();
    void _ready();
    void _process(const double delta);
    static void _register_methods();
};

#endif