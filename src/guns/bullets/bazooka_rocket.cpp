#include "bazooka_rocket.hpp"

BazookaRocket::BazookaRocket() {}
BazookaRocket::~BazookaRocket() {}

void BazookaRocket::_init() {
    Bullet::_init();
    DAMAGE = 1000;
    HEALTH = 10;
    LIFE_TIME = 60;

    local_dump_timeout = LOCAL_DAMP_TIME;
    local_dump_vector = Vector2();
    local_dump_length = 0;
}

void BazookaRocket::_ready() {
    Bullet::_ready();
    boom = (AnimatedSprite*) owner->get_node("boom");
    boom->connect("animation_finished", owner, "_animation_finish");
    audio_fire = (AudioStreamPlayer2D*) owner->get_node("audio_fire");
    audio_fire->play();
    dead_zone = (Area2D*) owner->get_node("dead_zone");
    dead_zone->set_collision_layer(layers::GRENADE_LAYER);
    dead_zone->set_collision_mask(layers::GRENADE_MASK);
    CircleShape2D* shape = (CircleShape2D*) ((CollisionShape2D*) dead_zone->get_node("collision"))->get_shape().ptr();
    SHOCK_WAVE_DISTANCE_SQUARED = pow(shape->get_radius(), 2);
}

void BazookaRocket::_animation_finish() {
    boom->set_visible(false);
}

void BazookaRocket::_collision(Variant body) {
    Godot::print("collision");
    decal = ((Node2D* )(Object* )body)->is_in_group("decals");
    _deactivate();
}

void BazookaRocket::_damage(Variant b) {
    Node2D* body = (Node2D*) (Object*) b;
    Vector2 dv = dead_zone->get_global_position();
    const Vector2 bv = body->get_global_position();
    real_t distance = dv.distance_squared_to(bv);
    Vector2 vector = (bv - dv).normalized();
    float percent = 1 - distance/SHOCK_WAVE_DISTANCE_SQUARED;

    if (body->has_method("damage")) {
        Array params = Array();
        params.append(DAMAGE*percent);
        params.append(vector*SHOCK_WAVE_FORCE*percent);
        body->call("damage", params);
    } else if (std::is_base_of(RigidBody2D, body)) {
        ((RigidBody2D&) body).apply_impulse(Vector2(), vector*SHOCK_WAVE_FORCE*percent);
    }
}

void BazookaRocket::damage(Variant d) {
    Bullet::damage(d);
}

void BazookaRocket::_deactivate() {
    Godot::print("deactivate");
    active = false;
    audio_fire->stop();
    sprite->set_visible(false);
    ((Light2D*) owner->get_node("decal"))->set_visible(true);
    owner->set_applied_force(Vector2());
    owner->set_mode(RigidBody2D::Mode::MODE_STATIC);
    if (owner->is_connected("body_entered", owner, "_collision")) {
        owner->disconnect("body_entered", owner, "_collision");
    }
    ((Particles2D*) owner->get_node("particles"))->set_emitting(false);
    boom->set_visible(true);
    boom->play();
    AudioStreamPlayer2D* audio_boom = (AudioStreamPlayer2D*) owner->get_node("audio_boom");
    audio_boom->play();
    Array bodies = dead_zone->get_overlapping_bodies();
    while (!bodies.empty()) {
        _damage(bodies.pop_front());
    }
    rocket_timeout = 4;
    Object* o = (Object*) owner->get_node("/root/world/player");
    Array params = Array();
    params.append(30);
    params.append(1);
    o->call("shuffle_camera", params);
}

void BazookaRocket::local_dump(Vector2 v) {
    local_dump_vector = v;
    local_dump_length = local_dump_vector.length();
}

void BazookaRocket::_process(const float delta) {
    Bullet::_process(delta);
}

void BazookaRocket::_integrate_forces(const Physics2DDirectBodyState *state) {
    if (local_dump_timeout > 0) {
        double step = state->get_step();
        local_dump_timeout -= step;
        Vector2 v = local_dump_vector.clamped(local_dump_length*(local_dump_timeout/LOCAL_DAMP_TIME));
        state->set_linear_velocity(state->get_linear_velocity() - v);
        local_dump_vector -= v;
    }
}

int BazookaRocket::get_damage() {
    return Bullet::get_damage();
}

void BazookaRocket::_register_methods() {
    register_method ((char *) "_init", &BazookaRocket::_init);
    register_method ((char *) "_ready", &BazookaRocket::_ready);
    register_method ((char *) "_process", &BazookaRocket::_process);
    register_method ((char *) "_animation_finish", &BazookaRocket::_animation_finish);
    register_method ((char *) "_damage", &BazookaRocket::_damage);
    register_method ((char *) "damage", &BazookaRocket::damage);
    register_method ((char *) "_collision", &BazookaRocket::_collision);
    register_method ((char *) "get_damage", &BazookaRocket::get_damage);
    register_method ((char *) "_integrate_forces", &BazookaRocket::_integrate_forces);
    register_method ((char *) "local_dump", &BazookaRocket::local_dump);
}
