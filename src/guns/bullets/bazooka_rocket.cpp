#include "bazooka_rocket.hpp"

BazookaRocket::BazookaRocket() {}
BazookaRocket::~BazookaRocket() {}

void BazookaRocket::_init() {
    Bullet::_init();
}

void BazookaRocket::_ready() {
    Bullet::_ready();
    _local_dump_timeout = _LOCAL_DAMP_TIME;
    _local_dump_vector = Vector2();
    _local_dump_length = 0;

    _boom = (AnimatedSprite*) get_node("boom");
    _boom->connect("animation_finished", this, "_animation_finish");
    _audio_fire = (AudioStreamPlayer2D*) get_node("audio_fire");
    _audio_fire->play();
    _dead_zone = (Area2D*) get_node("dead_zone");
    _dead_zone->set_collision_layer(layers::GRENADE_LAYER);
    _dead_zone->set_collision_mask(layers::GRENADE_MASK);
    CircleShape2D* shape = (CircleShape2D*) ((CollisionShape2D*) _dead_zone->get_node("collision"))->get_shape().ptr();
    _SHOCK_WAVE_DISTANCE_SQUARED = pow(shape->get_radius(), 2);
}

void BazookaRocket::_animation_finish() {
    _boom->set_visible(false);
}

void BazookaRocket::_collision(Variant body) {
    _decal = ((Node*) get_wrapper<Object>(body.operator godot_object*()))->is_in_group("decals");
    _deactivate();
}

void BazookaRocket::_damage(Variant b) {
    Node2D* body = (Node2D*) get_wrapper<Object>(b.operator godot_object*());
    Vector2 dv = _dead_zone->get_global_position();
    const Vector2 bv = body->get_global_position();
    double distance = dv.distance_squared_to(bv);
    Vector2 vector = (bv - dv).normalized();
    float percent = 1 - distance/_SHOCK_WAVE_DISTANCE_SQUARED;

    if (body->has_method("damage")) {
        body->call("damage", Array::make(_DAMAGE*percent, vector*_SHOCK_WAVE_FORCE*percent));
    } else {
        RigidBody2D* rb = (RigidBody2D*) (godot_object*) b;
        if (rb) {
            Godot::print(vector*_SHOCK_WAVE_FORCE*percent);
            rb->apply_impulse(Vector2(20, 20), vector*_SHOCK_WAVE_FORCE*percent);
            Godot::print("impulse1");
        }
    }
}

void BazookaRocket::damage(Variant d) {
    Bullet::damage(d);
}

void BazookaRocket::_deactivate() {
    _active = false;
    _audio_fire->stop();
    _sprite->set_visible(false);
    ((Light2D*) get_node("decal"))->set_visible(true);
    set_applied_force(Vector2());
    set_mode(RigidBody2D::Mode::MODE_STATIC);
    if (is_connected("body_entered", this, "_collision")) {
        disconnect("body_entered", this, "_collision");
    }
    ((Particles2D*) get_node("particles"))->set_emitting(false);
    _boom->set_visible(true);
    _boom->play();
    AudioStreamPlayer2D* audio_boom = (AudioStreamPlayer2D*) get_node("audio_boom");
    audio_boom->play();
    Array bodies = _dead_zone->get_overlapping_bodies();
    while (!bodies.empty()) {
        _damage(bodies.pop_front());
    }
    _rocket_timeout = 4;
    Object* o = (Object*) get_node("/root/world/player");
    o->call("shuffle_camera", Array::make(30, 1));
}

void BazookaRocket::local_dump(Vector2 v) {
    _local_dump_vector = v;
    _local_dump_length = _local_dump_vector.length();
}

void BazookaRocket::_process(const double delta) {
    Bullet::_process(delta);
}

void BazookaRocket::_integrate_forces(Physics2DDirectBodyState *state) {
    if (_local_dump_timeout > 0) {
        double step = state->get_step();
        _local_dump_timeout -= step;
        Vector2 v = _local_dump_vector.clamped(_local_dump_length*(_local_dump_timeout/_LOCAL_DAMP_TIME));
        state->set_linear_velocity(state->get_linear_velocity() - v);
        _local_dump_vector -= v;
    }
}

void BazookaRocket::_register_methods() {
    register_method ("_init", &BazookaRocket::_init);
    register_method ("_ready", &BazookaRocket::_ready);
    register_method ("_process", &BazookaRocket::_process);
    register_method ("_animation_finish", &BazookaRocket::_animation_finish);
    register_method ("damage", &BazookaRocket::damage);
    register_method ("_collision", &BazookaRocket::_collision);
    register_method ("_integrate_forces", &BazookaRocket::_integrate_forces);
    register_method ("local_dump", &BazookaRocket::local_dump);

    register_property<BazookaRocket, double>   ("main/health", &BazookaRocket::_health, int(10));
    register_property<BazookaRocket, double>   ("main/damage", &BazookaRocket::_DAMAGE, int(1000));
    register_property<BazookaRocket, double> ("main/lifetime", &BazookaRocket::_LIFE_TIME, double(60));
    register_property<BazookaRocket, double> ("main/gravity", &BazookaRocket::_GRAVITY, double(0));
    register_property<BazookaRocket, double> ("main/dumptime", &BazookaRocket::_LOCAL_DAMP_TIME, double(0.8));
    register_property<BazookaRocket, double>("main/shockwave", &BazookaRocket::_SHOCK_WAVE_FORCE, double(40000));
}
