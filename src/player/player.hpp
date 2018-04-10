#ifndef PLAYER_H
#define PLAYER_H
#include <core/Godot.hpp>
#include <core/Variant.hpp>
#include <KinematicBody2D.hpp>
#include <CanvasLayer.hpp>
#include <Area2D.hpp>
#include <AudioStreamPlayer2D.hpp>
#include <InputEvent.hpp>
#include <Input.hpp>
#include <GlobalConstants.hpp>
#include <SceneTree.hpp>
#include <ResourceLoader.hpp>
#include "camera.hpp"
#include "animation.hpp"
#include "../constants.hpp"
#include "../utils/utils.hpp"

using namespace godot;

class Gun;
class PlayerAnim;

class PlayerHenry: public KinematicBody2D {
    GODOT_CLASS (PlayerHenry, KinematicBody2D);
    
    static constexpr const double _ANIM_CLIMB_ANGLE = 0.68;
    
    static const Vector2 _FLOOR_NORMAL;
    static const Vector2 _DEFAULT_VECTOR;
    static const double _SLOPE_FRICTION;
    static const double _MAX_BOUNCES;
    static const double _FLOOR_MAX_ANGLE;    
    static const double _RECOIL_DEACCELERATION;
    
    const double _FOOT_STEP_MIN = utils::db2linear(-50);
    const double _FOOT_STEP_MAX = utils::db2linear(-20);
    const double _FOOT_STEP_LEN = _FOOT_STEP_MAX - _FOOT_STEP_MIN;
    
private:
    int _MAX_JUMP_COUNT;
    int _CONTROL_MODE;
    double _MAX_FALL_SPEED;    
    double _MAX_JUMP_SPEED;
    double _AIR_ACCELERATION;
    double _GRAVITY;
    double _INIT_JUMP_FORCE;
    double _INIT_MAX_SPEED;
    double _INIT_MAX_CLIMB_SPEED;
    double _INIT_ACCELERATION;
    double _DEAD_ZONE_X;
    double _DEAD_ZONE_Y;
    static const int GAMEPAD_ID = 0; 

    double _ACCELERATION;
    double _MAX_SPEED;
    double _MAX_CLIMB_SPEED;
    double _JUMP_FORCE;  

    double _health;
    CanvasLayer* _gui;    
    Gun* _gun;
    PlayerCamera* _camera;
    PlayerAnim* _anim;
    Node2D* _mouth;    
    AudioStreamPlayer2D* _step;
    AudioStreamPlayer2D* _step_metal;    
    
    void _footstep(const double ratio);
    void _footstep_metal(const double ratio);
    
    void _update_health(const double health);
    void _area_entered(const Area2D* area);
    void _area_exited(const Area2D* area);
    void _fire(const double delta);
    void _footstep_sound();
    void _vibrate(const double time, const double weak=1, const double strong=1, const double duration=0.3);
    void _set_ladder(const Area2D* ladder);
    void _recalc_mass();
    void _jump();
    void _drop_gun();    
    Vector2 _get_move_vector();
    Vector2 _get_direction();
    Input* _Input;
    
    // Movement
    bool _is_air_state;
    bool _is_climb_state;
    const Area2D* _climb_ladder;
    int _climb_ladder_direction;
    int _jump_count;
    void _climb_state(const double delta, const Vector2 m = Vector2());
    void _ground_state(const double delta, const Vector2 m = Vector2(), const double floor_ratio = NAN);
    void _air_state(const double delta, const Vector2 m = Vector2());
    void _look(const double rad, const double delta);
    void _look_default(const double delta);
    void _set_player_direction(const int direction);
    
    
    Vector2 _velocity;
    Vector2 _recoil;
    
public:
    static constexpr const char* MOUTH_AGGRESIVE = "mouth_aggresive";

    PlayerHenry();
    ~PlayerHenry();

    bool set_gun(String gun_class);    
    Vector2 get_velocity();
    void gun_reload();
    void gun_recoil(const Vector2 recoil_vector);
    void set_mouth(String mouth_type = "");
    void shuffle_camera(const double force, const double fade_out_time = 0.1);
    bool is_back();
    void damage(const double d, const Vector2 vector = Vector2());
    
    void _init();
    void _ready();
    void _input(const Ref<InputEvent> event);
    void _process(const double delta);
    void _physics_process(const double delta);
    
    static void _register_methods();
};

#endif