#ifndef AK47_H
#define AK47_H
#include "gun.hpp"
#include <AnimationPlayer.hpp>
#include <TextureRect.hpp>
#include <core/Color.hpp>

class AK47Gun: public Gun {
    GODOT_CLASS (AK47Gun, Node2D);

private:
    double _OVERHEAD_TIMEOUT;
    double _overheat_time;
    TextureRect* _overheat;
    AnimationPlayer* _animation;

protected:
    void _muzzle_flash();
    void _fire_start();
    void _fire_stop();
    Vector2 _get_bullet_velocity(Vector2 bullet_velocity, Vector2 player_velocity);

public:
    AK47Gun();
    ~AK47Gun();
    
    void _init();
    void _ready();
    void _process(const double delta);
    static void _register_methods();
};

#endif