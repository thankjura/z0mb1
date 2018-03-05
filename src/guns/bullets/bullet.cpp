#include "bullet.hpp"

Bullet::~Bullet() {}

void Bullet::_init() {

}

void Bullet::_ready() {
    rocket_timeout = LIFE_TIME;
    health = HEALTH;
    active = true;
    decal = false;

    owner->set_collision_layer(layers::BULLET_LAYER);
    owner->set_collision_mask(layers::BULLET_MASK);
    owner->set_contact_monitor(true);
    owner->set_max_contacts_reported(3);
    owner->set_gravity_scale(GRAVITY);
    owner->connect("body_entered", owner, "_collision");

    sprite = (Sprite*) owner->get_node("sprite");

    if (owner->has_node("particles")) {
        Vector2 s = owner->get_viewport_rect().get_size();
        ((Particles2D *)owner->get_node("particles"))->set_visibility_rect(Rect2(-s, s*2));
    }
}

void Bullet::_collision(Variant v) {
    Godot::print("collision2");
    Node2D* body = (Node2D*) (Object*) v;
    if (body->has_method("hit")) {
        Array params = Array();
        params.append(owner);
        body->call("hit", params);
    } else {
        decal = body->is_in_group("decals");
        _deactivate();
    }
}

void Bullet::_deactivate() {
    active = false;
    sprite->set_visible(false);
    owner->set_applied_force(Vector2());
    owner->set_mode(RigidBody2D::Mode::MODE_STATIC);
    owner->disconnect("body_entered", owner, "_collision");

    if (owner->has_node("light")) {
        ((Light2D*) owner->get_node("light"))->queue_free();
    }

    if (owner->has_node("particles")) {
        ((Particles2D*) owner->get_node("particles"))->set_emitting(false);
    }

    if (decal and owner->has_node("decal")) {
        ((CanvasItem*) owner->get_node("decal"))->set_visible(true);
    } else {
        owner->queue_free();
    }
}

void Bullet::damage(Variant d) {
    health -= (int) d;
    if (health <= 0) {
        _deactivate();
    }
}

void Bullet::_process(const float delta) {
    rocket_timeout -= delta;
    if (rocket_timeout <= 0) {
        Godot::print("queue");
        owner->queue_free();
    }
}

int Bullet::get_damage() {
    return Bullet::DAMAGE;
}
