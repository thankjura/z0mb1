#include "gun_entity.hpp"

GunEntity::GunEntity() {
    _TIMEOUT = 1;
    _wait_time = 0;
}
GunEntity::~GunEntity() {}

void GunEntity::_init() {}

void GunEntity::_ready() {
    _area = (Area2D*) get_node("area");
    _wait_time = _TIMEOUT;
    set_collision_layer(layers::GUN_ENTITY_LAYER);
    set_collision_mask(layers::GUN_ENTITY_MASK);
    _area->set_collision_layer(layers::GUN_ENTITY_AREA_LAYER);
    _area->set_collision_mask(layers::GUN_ENTITY_AREA_MASK);
    _area->connect("body_entered", this, "_collision");
    set_z_index(z_index::GUN_ENTITY_Z);
}

void GunEntity::_collision(Object* obj) {
    if (_wait_time > 0) {
        return;
    }

    if (obj->has_method("set_gun")) {
        if (obj->call("set_gun", Array::make(_GUN))) {
            queue_free();
        }
    }
}

void GunEntity::_process(const double delta) {
    if (_wait_time > 0) {
        _wait_time -= delta;
    }// else {
    //    Array bodies = _area->get_overlapping_bodies();
    //    for (int i = 0; i < bodies.size(); i++) {
    //       Object* obj = ((Object*) get_wrapper<Object>(bodies[i].operator godot_object*()));
    //        _collision(obj);
    //    }
    //}
}

void GunEntity::_register_methods() {
     register_method ("_ready",                     &GunEntity::_ready);
     register_method ("_process",                   &GunEntity::_process);
     register_method ("_collision",                   &GunEntity::_collision);

     register_property("main/timeout",              &GunEntity::_TIMEOUT,       double(1));
     register_property("main/gun_scene",            &GunEntity::_GUN,           String("res:://"));     
}
