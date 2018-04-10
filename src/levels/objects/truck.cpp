#include "truck.hpp"
#include "../../constants.hpp" 

ObjTruck::ObjTruck() {
    _FADE_TIME = 0.3;
    _CAMERA_ZOOM = 1.0;

    _is_visible = false;
    _fade_timeout = 0;    
}

ObjTruck::~ObjTruck() {}

void ObjTruck::_init() {}

void ObjTruck::_ready() {
    _sprite = (Sprite*) get_node("sprite/front");

    Area2D* inner_area = (Area2D*) get_node("inner_area");
    inner_area->set_collision_layer(layers::AUDIO_AREA_MASK);
    inner_area->set_collision_mask(layers::PLAYER_LAYER);
    inner_area->connect("body_entered", this, "_show");
    inner_area->connect("body_exited", this, "_hide");
    inner_area->set_meta("camera_zoom", _CAMERA_ZOOM);
    _sprite->set_visible(true);
    StaticBody2D* static_truck = (StaticBody2D*) get_node("static_truck");
    static_truck->set_collision_mask(0);
    static_truck->set_collision_layer(layers::GROUND_LAYER);
}

void ObjTruck::_show(const Node* obj) {
    Godot::print("show");
    if ((not _is_visible) and obj->get_name() == "player") {
         _fade_timeout = _FADE_TIME - _fade_timeout;
         _is_visible = true;
    }
}


void ObjTruck::_hide(const Node* obj) {
    if (_is_visible and obj->get_name() == "player") {
        _fade_timeout = _FADE_TIME - _fade_timeout;
        _is_visible = false;
    }
}

void ObjTruck::_process(const double delta) {
    if (_fade_timeout > 0) {
        _fade_timeout -= delta;
        if (_fade_timeout < 0) {
            _fade_timeout = 0;
        }
        
        Color m = _sprite->get_modulate();
        if (_is_visible) {            
            m.a = _fade_timeout/_FADE_TIME;
        } else {
            m.a = 1 - _fade_timeout/_FADE_TIME;
        }
        _sprite->set_modulate(m);
    }
}

void ObjTruck::_register_methods() {
    register_method("_init",                    &ObjTruck::_init);
    register_method("_ready",                   &ObjTruck::_ready);
    register_method("_show",                    &ObjTruck::_show);
    register_method("_hide",                    &ObjTruck::_hide);
    register_method("_process",                 &ObjTruck::_process);
    
    register_property("main/fade_time",         &ObjTruck::_FADE_TIME,     double(0.3));
    register_property("main/camera_zoom",       &ObjTruck::_CAMERA_ZOOM,   double(1.0));
}
