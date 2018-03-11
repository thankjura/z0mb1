#ifndef PLAYER_CAMERA_H
#define PLAYER_CAMERA_H
#include <core/Godot.hpp>
#include <Camera2D.hpp>

#include "../../constants.hpp"

using namespace godot;

class PlayerCamera: public GodotScript<Camera2D> {
    GODOT_CLASS (PlayerCamera);
    static int ZOOM_SPEED = 5;

private:
    Vector2 _init_zoom;
    float _shuffle_force;
    Vector2 _new_zoom;
    float _shuffle;
    float _shuffle_time;
    float _shuffle_timeout;
    Vector2 _camera_offset;

public:
    void _ready();
    void area_zoom(Variant area);
    void reset_zoom();
    void shuffle_camera(const float force, const fade_out_time = 0.1);
    void _process(const float delta);
};

#endif
