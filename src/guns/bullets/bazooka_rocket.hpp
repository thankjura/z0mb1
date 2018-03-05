#ifndef BAZOOKA_ROCKET_H
#define BAZOOKA_ROCKET_H
#include "bullet.hpp"
#include <Area2D.hpp>
#include <AnimatedSprite.hpp>
#include <AudioStreamPlayer2D.hpp>
#include <CircleShape2D.hpp>
#include <CollisionShape2D.hpp>
#include <Physics2DDirectBodyState.hpp>

class BazookaRocket: public Bullet {
    GODOT_CLASS (BazookaRocket);
    static constexpr const float LOCAL_DAMP_TIME = 0.8;
    static const int SHOCK_WAVE_FORCE = 40000;

private:
    double SHOCK_WAVE_DISTANCE_SQUARED;
    float local_dump_timeout;
    Vector2 local_dump_vector;
    float local_dump_length;
    AnimatedSprite* boom;
    Area2D* dead_zone;
    AudioStreamPlayer2D* audio_fire;

    void _animation_finish();
    void local_dump(Vector2 v);
    void _damage(Variant d);

protected:
    void _collision(Variant body);
    void _deactivate();

public:
    BazookaRocket();
    ~BazookaRocket();

    void _init();
    void _ready();
    void _process(const float delta);
    void damage(Variant d);
    int get_damage();

    void _integrate_forces(const Physics2DDirectBodyState *state);
    static void _register_methods();
};

#endif
