#ifndef PLAYER_ANIMATION_H
#define PLAYER_ANIMATION_H
#include <core/Godot.hpp>
#include <AnimationTreePlayer.hpp>
#include <Node2D.hpp>
#include <SceneTree.hpp>
#include "../utils/utils.hpp"
#include "../guns/gun.hpp"
#include <map>

using namespace godot;

class Gun;

class PlayerAnim: public AnimationTreePlayer {
    GODOT_CLASS (PlayerAnim, AnimationTreePlayer);
    
    static constexpr const char* _GROUND_BLEND_NODE = "ground_blend";
    static constexpr const char* _WALK_BLEND_NODE = "walk_blend";
    static constexpr const char* _GROUND_SCALE_NODE = "ground_scale";
    static constexpr const char* _WALK_DIRECTION_NODE = "walk_direction";
    static constexpr const char* _WALK_ANGLE_BLEND = "walk_angle";
    static constexpr const char* _WALK_ANGLE_REVERSE_BLEND = "walk_angle_reverse";
    static constexpr const char* _RUN_DIRECTION_NODE = "run_direction";
    static constexpr const char* _STATE_NODE = "ground_air_transition";
    static constexpr const char* _AIM_BLEND_NODE = "aim_blend";
    static constexpr const char* _AIM_SWITCH_NODE = "aim_transition";
    static constexpr const char* _SHOTGUN_RELOAD_NODE = "shotgun_reload";
    static constexpr const char* _ANIMATION_WALK_NODE = "anim_walk";
    static constexpr const char* _BAZOOKA_RELOAD_NODE = "bazooka_reload";
    static constexpr const char* _AIM_SEEK_NODE = "gun_angle";
    static constexpr const char* _CLIMB_TRANSITION_NODE = "climb_transition";
    static constexpr const char* _CLIMB_SCALE_NODE = "climb_scale";
    static constexpr const char* _CLIMB_TOP_SEEK = "climb_top_seek";
    static constexpr const char* _CLIMB_TOP_BLEND = "climb_top_blend";
    static constexpr const char* _IDLE_CLIMB_BLEND = "blend_idle_floor_angle";
    
    const std::string _AIM_SHOTGUN_NAME = "aim_shotgun5";
    const std::string _AIM_BAZOOKA_NAME = "aim_bazooka";
    const std::string _AIM_MINIGUN_NAME = "aim_minigun";
    const std::string _AIM_PISTOL_NAME = "aim_pistol";
        
private:
    double _RUN_SPEED;
    double _GROUND_SCALE_RATE;
    double _CLIMB_SCALE_RATE;
    double _AIM_SPEED;
    double _FLOOR_RATIO_TIME;
    double _SHOTGUN_RELOAD_IN;
    double _SHOTGUN_RELOAD_OUT;    
    
    enum State {
        STATE_GROUND,
        STATE_JUMP_UP,
        STATE_JUMP_DOWN,
        STATE_CLIMB
    };
    
    enum HandType {
        HT_DEFAULT, 
        HT_CLIMB,
        HT_PISTOL,
        HT_SHOTGUN,
        HT_AK47,
        HT_MINIGUN,
        HT_BAZOOKA
    };
    
    enum ClimbDirection {
        CD_UP,
        CD_DOWN
    };
    
    std::map<std::string, int> _AIM;
    
    State _current_state;
    double _current_aim_angle;
    double _reload_in_timeout;
    double _reload_out_timeout;
    double _reload_in_time;
    double _reload_out_time;
    
    Gun* _gun;
    HandType _current_hand_type;
    double _floor_ratio;
    double _new_floor_ratio;
    double _floor_ratio_timeout;
    
    int _player_direction;    
    bool _set_state(State state);
    void _set_hand_type(HandType hand_type);
    void _set_gun_position();
    void _set_hand();
    void _start_gun_reload();
    void _stop_gun_reload();
    
    
public:    
    static constexpr const double CLIMB_LADDER_TOP_DISTANCE = 80;
    static constexpr const double CLIMB_LADDER_BOTTOM_DISTANCE = 50;

    PlayerAnim();
    ~PlayerAnim();

    void set_floor_ratio(double ratio, int direction);
    void walk(const double velocity, const double delta, const int direction, const double max_speed);
    void jump(const Vector2 velocity);
    void aim(const double angle, const double delta);
    void climb(const Vector2 velocity, const double delta, const double max_climb_speed, double distance);
    void set_player_direction(const int direction);
    void set_gun(Gun* gun);
    void drop_gun();
    void gun_reload();
    
    void _init();
    void _ready();
    void _process(const double delta);  
    
    static void _register_methods(); 
};

#endif