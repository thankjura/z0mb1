#ifndef BAZOOKA_ROCKET_H
#define BAZOOKA_ROCKET_H
#include "bullet.hpp"
#include <Area2D.hpp>
#include <AnimatedSprite.hpp>
#include <AudioStreamPlayer2D.hpp>
#include <CircleShape2D.hpp>
#include <CollisionShape2D.hpp>
#include <Physics2DDirectBodyState.hpp>

class PlayerHenry;
#include "../../player/player.hpp"

class BazookaRocket: public Bullet {
    GODOT_CLASS (BazookaRocket, Bullet);

private:
    double _SHOCK_WAVE_FORCE;
    double _SHOCK_WAVE_DISTANCE_SQUARED;
    double _LOCAL_DAMP_TIME;
    double _local_dump_timeout;
    double _local_dump_length;

    Vector2 _local_dump_vector;
    AnimatedSprite* _boom;
    Area2D* _dead_zone;
    AudioStreamPlayer2D* _audio_fire;

    void _animation_finish();
    void _damage(Variant d);
    
    PlayerHenry* _player;

protected:
    void _collision(Node2D* body);
    void _deactivate();

public:
    BazookaRocket();
    ~BazookaRocket();

    void _init();
    void _ready();
    void _process(const double delta);

    void local_dump(Vector2 v);

    void _integrate_forces(Physics2DDirectBodyState *state);
    static void _register_methods();
};

#endif
