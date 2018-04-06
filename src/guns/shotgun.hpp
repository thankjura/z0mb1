#ifndef SHOTGUN_H
#define SHOTGUN_H
#include "gun.hpp"
#include <AnimationPlayer.hpp>
#include <AudioStreamPlayer2D.hpp>

class Shotgun: public Gun {
    GODOT_CLASS (Shotgun, Node2D);

private:
    int _PELLETS_PER_SHOOT;
    AnimationPlayer* _animation;
    AudioStreamPlayer2D* _audio_reload;
    AudioStreamPlayer2D* _audio_fire;

public:
    Shotgun();
    ~Shotgun();
    
    void _end_animation(Variant anim_name);
    void _create_pellet(const Vector2 spawn_point, const Vector2 bullet_velocity);
    void _reset_view();
    void fire(const double delta, const Vector2 velocity);
    
    void _init();
    void _ready();
    void _process(const double delta);
    static void _register_methods();
};

#endif