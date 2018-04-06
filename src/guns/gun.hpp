#ifndef GUN_H
#define GUN_H
#include <core/Godot.hpp>
#include <Node.hpp>
#include <Node2D.hpp>
#include <PackedScene.hpp>
#include <ResourceLoader.hpp>
#include <KinematicBody2D.hpp>
#include <core/Vector2.hpp>
#include <core/String.hpp>
#include <Resource.hpp>
#include <SceneTree.hpp>
#include <RigidBody2D.hpp>
#include <AudioStreamPlayer2D.hpp>

using namespace godot;

class PlayerHenry;
#include "../player/player.hpp"

class Gun: public Node2D {
    GODOT_CLASS (Gun, Node2D);
    enum OFFSET_TYPE {
        DEFAULT = 1,
        CLIMB
    };

protected:
    std::string _AIM_NAME;

    Ref<PackedScene> _BULLET;
    Ref<PackedScene> _ENTITY;
    Ref<PackedScene> _SHELL;

    double _SPEED;
    double _VIEWPORT_SHUTTER;
    double _DROP_ANGULAR;
    double _ANIM_DEAD_ZONE_TOP;
    double _ANIM_DEAD_ZONE_BOTTOM;
    double _SPREADING;
    double _HEAVINES;
    double _TIMEOUT;
    Vector2 _OFFSET;
    Vector2 _CLIMB_OFFSET;
    Vector2 _DROP_VELOCITY;
    Vector2 _RECOIL;
    Vector2 _EJECT_SHELL_VECTOR;

    double _wait_ready;
    bool _fired;
    OFFSET_TYPE _current_offset_type;

    virtual void _muzzle_flash();
    virtual void _fire_start();
    virtual void _fire_stop();
    virtual void _eject_shell();
    virtual void _recoil(const Vector2 recoil_vector);
    virtual void _shutter_camera();
    virtual void _play_sound();
    virtual Vector2 _get_bullet_vector();
    virtual Vector2 _get_bullet_velocity(Vector2 bullet_velocity, Vector2 player_velocity);
    virtual Vector2 _get_bullet_position(const double gun_angle);

    Node* _world;
    PlayerHenry* _player;

public:    
    Gun();
    virtual ~Gun();

    virtual void fire(const double delta, const Vector2 velocity);
    virtual void drop();

    double get_heavines();
    double get_dead_zone_top();
    double get_dead_zone_bottom();
    const char* get_anim_name();

    void _init();
    void _ready();
    void default_offset();
    void climb_offset();
    void _process(const double delta);
};

#endif
