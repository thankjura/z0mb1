#ifndef SOLDER_ANIM_H
#define SOLDER_ANIM_H
#include <core/Godot.hpp>
#include <core/Vector2.hpp>
#include <KinematicBody2D.hpp>
#include <AnimationTreePlayer.hpp>

using namespace godot;

class SolderAnim: public AnimationTreePlayer {
    GODOT_CLASS(SolderAnim, AnimationTreePlayer);

    static constexpr const char* _GROUND_BLEND_NODE = "ground_blend";
    static constexpr const char* _WALK_SCALE_NODE = "walk_scale";
    static constexpr const char* _AIM_SEEK_NODE = "aim";
    static constexpr const char* _AIM_BLEND_NODE = "aim_blend";
    static constexpr const char* _DIE_TRANSITION_NODE = "die_transition";
    static constexpr const char* _HIT_ONESHOT_NODE = "hit_oneshot";
    static constexpr const char* _HIT_TRANSITION_NODE = "hit_transition";
    static constexpr const char* _JUMP_ONESHOT = "jump_oneshot";
    static constexpr const char* _JUMP_SCALE = "jump_scale";
    
private:
    double _AIM_SPEED;
    Vector2 _DEFAULT_VECTOR;

    enum AnimState {
        ANIM_IDLE,
        ANIM_WALK,
        ANIM_DIE,
        ANIM_REBOUND
    };
    
    enum DieAnim {
        NONE,
        ON_FACE,
        ON_BACK
    };
    
    enum HitAnim {
        HEAD_BACK,
        HEAD_FACE
    };
    
    double _current_aim_angle;
    AnimState _current_state;
    Vector2 _last_hit_vector;
    bool _aim_enabled;
    
    bool _set_state(AnimState state);
    void _set_aim(bool state);
    
public:
    SolderAnim();
    ~SolderAnim();

    void walk(const double scale = 1);
    void idle();
    void aim(const double aim_angle, const double delta);
    void die();
    void hit_head(const Vector2 vector);
    void hit_body(const Vector2 vector);
    void init_jump();
    void pause_jump();
    void play_jump();

    void _init();
    void _ready();
    void _process(const double delta);
    
    static void _register_methods();
};

#endif
