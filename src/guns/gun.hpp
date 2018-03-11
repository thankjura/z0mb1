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
#include <AudioStreamPlayer2D.hpp>

using namespace godot;

class Gun: public GodotScript<Node2D> {
    GODOT_CLASS (Gun);
    enum OFFSET_TYPE {
        DEFAULT = 1,
        CLIMB
    };

protected:
    Ref<PackedScene> _BULLET = NULL;
    Ref<PackedScene> _ENTITY = NULL;
    Ref<PackedScene> _SHELL = NULL;

    String _AIM_NAME;

    int _SPEED;
    int _VIEWPORT_SHUTTER;
    int _DROP_ANGULAR;
    int _ANIM_DEAD_ZONE_TOP;
    int _ANIM_DEAD_ZONE_BOTTOM;
    float _SPREADING;
    float _HEAVINES;
    float _TIMEOUT;
    Vector2 _OFFSET;
    Vector2 _CLIMB_OFFSET;
    Vector2 _DROP_VELOCITY;
    Vector2 _RECOIL;
    Vector2 _EJECT_SHELL_VECTOR;

    float _wait_ready;
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

    Node* world;
    KinematicBody2D* player;

public:
    Gun();
    virtual ~Gun();

    virtual void fire(const float delta, const Vector2 velocity);
    virtual void drop();

    void _init();
    void _ready();
    void default_offset();
    void climb_offset();
    void _process(const float delta);
};

#endif
