#ifndef PLAYER_CAMERA_H
#define PLAYER_CAMERA_H
#include <core/Godot.hpp>
#include <Camera2D.hpp>
#include <Area2D.hpp>
#include "../constants.hpp"

using namespace godot;

class PlayerCamera: public Camera2D {
    GODOT_CLASS (PlayerCamera, Camera2D);

private:
    double _ZOOM_SPEED;
    double _SHUFFLE_FORCE;

    Vector2 _init_zoom;    
    Vector2 _new_zoom;
    double _shuffle;
    double _shuffle_time;
    double _shuffle_timeout;
    Vector2 _camera_offset;

public:    
    void area_zoom(Area2D* area);
    void reset_zoom();
    void shuffle_camera(const double force, const double fade_out_time = 0.1);
    
    PlayerCamera();
    ~PlayerCamera();
    
    void _init();
    void _ready();
    void _process(const double delta);
    
    static void _register_methods();
};

#endif
