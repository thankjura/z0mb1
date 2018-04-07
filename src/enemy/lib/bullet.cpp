#include "bullet.hpp"

EnemyBullet::EnemyBullet() {
    _LIFE_TIME = 10;
    _DAMAGE = 30;
}
EnemyBullet::~EnemyBullet() {}

void EnemyBullet::_init() {}

void EnemyBullet::_ready() {
    _area = (Area2D*) get_node("area"); 
    _area->set_collision_layer(layers::ENEMY_BULLET_LAYER);
    _area->set_collision_mask(layers::ENEMY_BULLET_MASK);    
    set_collision_layer(0);
    set_collision_mask(0);
    
    set_contact_monitor(true);
    set_max_contacts_reported(1);
    
    _area->connect("area_entered", this, "_collision");
    _area->connect("body_entered", this, "_collision");
    _sprite = (Sprite*) get_node("sprite");
    _world = (Node2D*) get_tree()->get_current_scene();
    if (has_node("particles")) {
        Vector2 s = get_viewport_rect().size;
        _particles = (Particles2D*) get_node("particles");
        _particles->set_visibility_rect(Rect2(-s, s*2));
    }
    
    _timer = _LIFE_TIME;
}

void EnemyBullet::_deactivate() {
    _active = false;
    _sprite->set_visible(false);
    _area->queue_free();
    set_applied_force(Vector2());
    set_mode(MODE_STATIC);
    
    if (has_node("light")) {
        get_node("light")->queue_free();
    }

    if (_particles) {
        _particles->set_emitting(false);
    }

    if (_decal and has_node("decal")) {
        ((Node2D*) get_node("decal"))->set_visible(true);
    } else {
        queue_free();
    }
}

void EnemyBullet::_collision(Object* obj) {
    if (obj->has_method("damage")) {
        obj->call("damage", Array::make(_DAMAGE));
        _deactivate();
    } else {
        _decal = ((Node*) obj)->is_in_group("decals");
        _deactivate();
    }
}


void EnemyBullet::_process(const double delta) {
    _timer -= delta;
    if (_timer <= 0) {
        queue_free();
    }
}

void EnemyBullet::_register_methods() {
     register_method(                       "_init",            &EnemyBullet::_init);
     register_method(                       "_ready",           &EnemyBullet::_ready);
     register_method(                       "_process",         &EnemyBullet::_process);
     register_method(                       "_collision",       &EnemyBullet::_collision);

     register_property<EnemyBullet, double>("main/life_time",   &EnemyBullet::_LIFE_TIME,       double(10));
     register_property<EnemyBullet, double>("main/damage",      &EnemyBullet::_DAMAGE,          double(30));
}
