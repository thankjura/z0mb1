#include "bullet.hpp"

Bullet::Bullet() {
    _DAMAGE = 11;
    printf("ptr orig: %p", this);
    Godot::print("\n");
}
Bullet::~Bullet() {}

void Bullet::_init() {}

void Bullet::_ready() {
    _rocket_timeout = _LIFE_TIME;
    _active = true;
    _decal = false;

    set_collision_layer(layers::BULLET_LAYER);
    set_collision_mask(layers::BULLET_MASK);
    set_contact_monitor(true);
    set_max_contacts_reported(3);
    set_gravity_scale(_GRAVITY);
    connect("body_entered", this, "_collision");

    _sprite = (Sprite*) get_node("sprite");

    if (has_node("particles")) {
        Vector2 s = get_viewport_rect().get_size();
        ((Particles2D *) get_node("particles"))->set_visibility_rect(Rect2(-s, s*2));
    }
}

void Bullet::_collision(Node2D* body) {
    if (body->has_method("damage")) {
        body->call("damage", Array::make(_DAMAGE, get_linear_velocity()));
    } else {
        _decal = body->is_in_group("decals");
        _deactivate();
    }
}

void Bullet::_deactivate() {
    _active = false;
    _sprite->set_visible(false);
    set_applied_force(Vector2());
    set_mode(RigidBody2D::Mode::MODE_STATIC);
    disconnect("body_entered", this, "_collision");

    if (has_node("light")) {
        ((Light2D*) get_node("light"))->queue_free();
    }

    if (has_node("particles")) {
        ((Particles2D*) get_node("particles"))->set_emitting(false);
    }

    if (_decal and has_node("decal")) {
        ((CanvasItem*) get_node("decal"))->set_visible(true);
    } else {
        queue_free();
    }
}

void Bullet::damage(const double d, const Vector2 vector) {
    _health -= (double) d;
    if (_health <= 0) {
        _deactivate();
    }
}

const double Bullet::get_damage() {
    printf("%f", _DAMAGE);
    Godot::print("xxxx11");
    return _DAMAGE;
}

void Bullet::_process(const double delta) {
    _rocket_timeout -= delta;
    if (_rocket_timeout <= 0) {
        queue_free();
    }
}
