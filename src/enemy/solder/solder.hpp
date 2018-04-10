#ifndef ENEMY_SOLDER_H
#define ENEMY_SOLDER_H
#include <core/Godot.hpp>
#include <core/Vector2.hpp>
#include <KinematicBody2D.hpp>
#include <RayCast2D.hpp>
#include <Area2D.hpp>
#include <AudioStreamPlayer2D.hpp>
#include <PackedScene.hpp>
#include <RigidBody2D.hpp>

#include "../enemy.hpp"
#include "animation.hpp"

using namespace godot;

class EnemySolder: public Enemy {
    GODOT_CLASS(EnemySolder, KinematicBody2D);

private:
    SolderAnim* _animation;
    AudioStreamPlayer2D* _audio_fire;
    
    enum SolderState {
        SOLDER_IDLE,
        SOLDER_WALK,
        SOLDER_AIM,
        SOLDER_RELOCATE,
        SOLDER_PREJUMP,
        SOLDER_JUMP
    };
    
    double _ATTACK_DISTANCE;
    double _ATTACK_DAMAGE;
    double _BACKSLIDE_DISTANCE;
    double _MAX_SPEED;
    double _MAX_RUN_SPEED;
    double _MAX_JUMP;
    double _ACCELERATION;
    double _AIM_TIME;

    Vector2 _DEFAULT_VECTOR;
    Node2D* _bullet_position;
    Ref<PackedScene> _BULLET;
    double _BULLET_SPEED;

    double _BODY_STRENGTH;
    double _HEAD_STRENGTH;
    
    Area2D* _body_area;
    Area2D* _head_area;
    Node2D* _bullet_spawn;
    Node2D* _world;
    Node2D* _base;
    RayCast2D* _ray_bottom;
    RayCast2D* _ray_middle;
    RayCast2D* _ray_height;
    RayCast2D* _eyes;

    SolderState _current_state;    
    SolderState _next_state;
    
    int _next_direction;
    int _direction;
    double _switch_state_timeout;
    Vector2 _jump_vector;
    double _aim_timeout;
    
    void _fire();
    void _aim(const double delta);
    void _body_hit(Object* obj);
    void _head_hit(Object* obj);
    
    void _init_jump(const double height);
    void _start_jump();
    void _end_jump();
    
    bool _is_player_visible();
    void _set_direction(const int direction);
    int _get_direction();
    
public:
    EnemySolder();
    ~EnemySolder();
    
    void change_direction(const double time, int direction);
    void die();    
        
    void _init();
    void _ready();    
    void _process(const double delta);
    void _physics_process(const double delta);
    
    static void _register_methods();
};

#endif