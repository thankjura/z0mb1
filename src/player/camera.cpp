#include "camera.hpp"

PlayerCamera::PlayerCamera() {
    _ZOOM_SPEED = 5;
    _SHUFFLE_FORCE = -0.8;
    _init_zoom = Vector2(1,1);
    _shuffle = 0;
    _shuffle_time = 0;
    _shuffle_timeout = 0;
}

PlayerCamera::~PlayerCamera() {}

void PlayerCamera::_init() {}
void PlayerCamera::_ready() {
    _init_zoom = Vector2(get_zoom());    
    _new_zoom = Vector2(_init_zoom);
    _camera_offset = get_offset();
}

void PlayerCamera::area_zoom(Area2D* area) {
    _new_zoom = Vector2(_init_zoom * ((int) area->get_meta("camera_zoom")));
}

void PlayerCamera::reset_zoom() {
    _new_zoom = Vector2(_init_zoom);
}

void PlayerCamera::shuffle_camera(const double force, const double fade_out_time) {
    _shuffle = force * pow((_new_zoom.y/_init_zoom.y), 2);
    set_offset(Vector2(_camera_offset.x, _camera_offset.y + _shuffle));
    _shuffle_timeout = fade_out_time;    
}

void PlayerCamera::_process(const double delta) {
    Vector2 zoom = get_zoom();
    if (_new_zoom != zoom) {
        set_zoom(zoom.linear_interpolate(_new_zoom, _ZOOM_SPEED * delta));
    }
    
    if (_shuffle_timeout > 0) {
        _shuffle_timeout -= delta;
        
        if (_shuffle_timeout <= 0) {
            set_offset(_camera_offset);
        } else {
            _shuffle_time += delta;
            if (_shuffle_time > 0.1) {
                _shuffle *= _SHUFFLE_FORCE;
                set_offset(Vector2(_camera_offset.x, _camera_offset.y + _shuffle));
                _shuffle_time = 0;
            }
        }
    }
}

void PlayerCamera::_register_methods() {
    register_method("_init",                    &PlayerCamera::_init);
    register_method("_ready",                   &PlayerCamera::_ready);
    register_method("_process",                 &PlayerCamera::_process);

    register_property("main/zoom_speed",        &PlayerCamera::_ZOOM_SPEED,      double(5));
    register_property("main/shuffle_force",     &PlayerCamera::_SHUFFLE_FORCE,   double(-0.8));    
}
