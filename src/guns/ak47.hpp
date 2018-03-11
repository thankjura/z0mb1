#ifndef AK47_H
#define AK47_H
#include "gun.hpp"
#include <AnimationPlayer.hpp>
#include <TextureRect.hpp>
#include <core/Color.hpp>

class AK47Gun: public Gun {
    GODOT_CLASS (AK47Gun);

private:
    static constexpr float _OVERHEAD_TIMEOUT = 3;
    float _overheat_time;

protected:
    void _muzzle_flash();
    void _fire_start();
    void _fire_stop();
    Vector2 _get_bullet_velocity(Vector2 bullet_velocity, Vector2 player_velocity);

public:
    AK47Gun();
    ~AK47Gun();

    void default_offset();
    void climb_offset();
    void drop();
    void fire(const float delta, const Vector2 velocity);

    void _init();
    void _ready();
    void _process(const float delta);
    static void _register_methods();
};

#endif