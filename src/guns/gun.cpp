#include "gun.hpp"

Gun::Gun() {}

Gun::~Gun() {};

void Gun::_init() {
    _wait_ready = 0;
    _fired = false;
}

void Gun::_ready() {
    set_position(_OFFSET);
   
    SceneTree* scene = get_tree();
    _world = scene->get_current_scene();
    Node* parent = get_parent();
    _player = as<PlayerHenry>(parent->get_owner());
}

void Gun::default_offset() {
    if (_current_offset_type != DEFAULT) {
        set_position(_OFFSET);
        set_z_index(0);
        _current_offset_type = DEFAULT;
    }
}

void Gun::climb_offset() {
    if (_current_offset_type != CLIMB) {
        set_position(_CLIMB_OFFSET);
        set_z_index(-4);
        _current_offset_type = CLIMB;
    }
}

Vector2 Gun::_get_bullet_vector() {
    Vector2 out = (((Node2D*) get_node("bullet_spawn"))->get_global_position() - get_global_position());
    out.normalize();
    if (_SPREADING) {
        out = out.rotated(_SPREADING - ((rand() / static_cast <double> (RAND_MAX))*_SPREADING*2));
    }

    return out;
}

Vector2 Gun::_get_bullet_position(const double gun_angle) {
    return ((Node2D*) get_node("bullet_spawn"))->get_global_position();
}

void Gun::_eject_shell() {
    if (_SHELL != NULL) {
        Vector2 v = _EJECT_SHELL_VECTOR * (1 + ((rand() / (static_cast<double> (RAND_MAX)) * 0.1)));
        RigidBody2D* s = (RigidBody2D*) _SHELL->instance();
        Node2D* shell_gate = (Node2D*) get_node("shell_gate");
        s->set_global_position(shell_gate->get_global_position());
        double global_rot = shell_gate->get_global_rotation();
        double ext_rotate = 0.2;
        if (std::abs(global_rot) > 1.5707963267948966) {
            v.x = -v.x;
            global_rot = 3.121592653589793 - global_rot;
            ext_rotate = -ext_rotate;
        }
        s->rotate(global_rot);
        s->set_applied_torque(-300 + (rand() / (static_cast<double> ((RAND_MAX) / 800))));
        _world->add_child(s);
        Vector2 impulse = v.rotated(global_rot + ext_rotate);
        s->apply_impulse(Vector2(), impulse + ((Vector2) _player->get_velocity()));
    }
}

Vector2 Gun::_get_bullet_velocity(const Vector2 bullet_velocity, const Vector2 player_velocity) {
    return bullet_velocity * _SPEED;
}

void Gun::fire(const double delta, const Vector2 velocity) {
    if (_wait_ready > 0) {
        return;
    }

    _wait_ready = _TIMEOUT;

    if (!_fired) {
        _fired = true;
        _fire_start();
    }

    _shutter_camera();
    _muzzle_flash();
    _play_sound();

    RigidBody2D* bullet = (RigidBody2D*) _BULLET->instance();
    Vector2 bullet_velocity = _get_bullet_vector();
    double gun_angle = Vector2(1,0).angle_to(bullet_velocity);
    _recoil(_RECOIL.rotated(bullet_velocity.angle()));
    bullet->set_global_rotation(gun_angle);
    Vector2 vv = _get_bullet_velocity(bullet_velocity, velocity);
    bullet->set_axis_velocity(vv);
    bullet->set_global_position(_get_bullet_position(gun_angle));
    _world->add_child(bullet);
}

void Gun::_fire_start() {}

void Gun::_fire_stop() {}

void Gun::_muzzle_flash() {}

void Gun::_recoil(const Vector2 recoil_vector) {
    _player->gun_recoil(recoil_vector);
}

void Gun::_shutter_camera() {
    if (_VIEWPORT_SHUTTER) {
        _player->shuffle_camera(_VIEWPORT_SHUTTER);
    }
}

void Gun::_play_sound() {
    if (has_node("audio_fire")) {
        ((AudioStreamPlayer2D*) get_node("audio_fire"))->play();
    }
}

void Gun::drop() {
    if (not _ENTITY.empty()) {
        Ref<PackedScene> e = ResourceLoader::get_singleton()->load(_ENTITY.c_str());
        RigidBody2D* entity =  (RigidBody2D*) e->instance();
        Vector2 gp = get_global_position();
        entity->set_global_position(gp);
        if (gp.x <= ((Node2D*) get_node("bullet_spawn"))->get_global_position().x) {
            entity->set_angular_velocity(_DROP_ANGULAR);
            entity->set_linear_velocity(Vector2(-_DROP_VELOCITY.x, _DROP_VELOCITY.y));
        } else {
            entity->set_angular_velocity(-_DROP_ANGULAR);
            entity->set_linear_velocity(_DROP_VELOCITY);
        }

        _world->add_child(entity);
    }

    queue_free();
}

double Gun::get_heavines() {
    return _HEAVINES;
}

double Gun::get_dead_zone_top() {
    return _ANIM_DEAD_ZONE_TOP;
}

double Gun::get_dead_zone_bottom() {
    return _ANIM_DEAD_ZONE_BOTTOM;
}

const char* Gun::get_anim_name() {
    return _AIM_NAME.c_str();
}

void Gun::_process(const double delta) {
    if (_wait_ready > 0) {
        _wait_ready -= delta;
    } else if (_fired) {
        _fired = false;
        _fire_stop();
    }
}
