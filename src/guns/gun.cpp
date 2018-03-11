#include "gun.hpp"
#include "bullets/bullet.hpp"

Gun::Gun() {
    _wait_ready = 0;
    _fired = false;

    //_current_offset_type = NULL;
}

Gun::~Gun() {};

void Gun::_init() {}

void Gun::_ready() {
    owner->set_position(_OFFSET);
    SceneTree* scene = owner->get_tree();
    world = scene->get_current_scene();
    Node* parent = owner->get_parent();
    player = (KinematicBody2D*) parent->get_owner();
}

void Gun::default_offset() {
    if (_current_offset_type != DEFAULT) {
        owner->set_position(_OFFSET);
        owner->set_z_index(0);
        _current_offset_type = DEFAULT;
    }
}

void Gun::climb_offset() {
    if (_current_offset_type != CLIMB) {
        owner->set_position(_CLIMB_OFFSET);
        owner->set_z_index(-4);
        _current_offset_type = CLIMB;
    }
}

Vector2 Gun::_get_bullet_vector() {
    Vector2 out = (((Node2D*) owner->get_node("bullet_spawn"))->get_global_position() - owner->get_global_position());
    out.normalize();
    if (_SPREADING) {
        out = out.rotated(_SPREADING - ((rand() / static_cast <float> (RAND_MAX))*_SPREADING*2));
    }

    return out;
}

Vector2 Gun::_get_bullet_position(const double gun_angle) {
    return ((Node2D*)owner->get_node("bullet_spawn"))->get_global_position();
}

void Gun::_eject_shell() {
    if (_SHELL != NULL) {
        Vector2 v = _EJECT_SHELL_VECTOR * (1 + ((rand() / (static_cast<float> (RAND_MAX)) * 0.1)));
        RigidBody2D* s = (RigidBody2D*) _SHELL.ptr()->instance();
        Node2D* shell_gate = (Node2D*) owner->get_node("shell_gate");
        s->set_global_position(shell_gate->get_global_position());
        double global_rot = shell_gate->get_global_rotation();
        double ext_rotate = 0.2;
        if (abs(global_rot) > 1.5707963267948966) {
            v.x = -v.x;
            global_rot = 3.121592653589793 - global_rot;
            ext_rotate = -ext_rotate;
        }
        s->rotate(global_rot);
        s->set_applied_torque(-300 + (rand() / (static_cast<float> ((RAND_MAX) / 800))));
        world->add_child(s);
        //TODO: after implements player
        Vector2 impulse = v.rotated(global_rot + ext_rotate);
        s->apply_impulse(Vector2(), impulse + ((Vector2) player->call("get_velocity")));
    }
}

Vector2 Gun::_get_bullet_velocity(const Vector2 bullet_velocity, const Vector2 player_velocity) {
    return bullet_velocity * _SPEED;
}

void Gun::fire(const float delta, const Vector2 velocity) {
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

    RigidBody2D* bullet = (RigidBody2D*) _BULLET.ptr()->instance();
    Vector2 bullet_velocity = _get_bullet_vector();
    double gun_angle = Vector2(1,0).angle_to(bullet_velocity);
    _recoil(_RECOIL.rotated(bullet_velocity.angle()));
    bullet->set_global_rotation(gun_angle);
    Vector2 vv = _get_bullet_velocity(bullet_velocity, velocity);
    bullet->set_axis_velocity(vv);
    bullet->set_global_position(_get_bullet_position(gun_angle));
    world->add_child(bullet);
}

void Gun::_fire_start() {}

void Gun::_fire_stop() {}

void Gun::_muzzle_flash() {}

void Gun::_recoil(const Vector2 recoil_vector) {
    //TODO: after player implements
    player->call("gun_recoil", Array::make(recoil_vector));
}

void Gun::_shutter_camera() {
    if (_VIEWPORT_SHUTTER) {
        player->call("shuffle_camera", Array::make(_VIEWPORT_SHUTTER));
    }
}

void Gun::_play_sound() {
    if (owner->has_node("audio_fire")) {
        ((AudioStreamPlayer2D*) owner->get_node("audio_fire"))->play();
    }
}

void Gun::drop() {
    if (_ENTITY != NULL) {
        RigidBody2D* entity = (RigidBody2D*) _ENTITY.ptr()->instance();
        Vector2 gp = owner->get_global_position();
        entity->set_global_position(gp);
        if (gp.x <= ((Node2D*) owner->get_node("bullet_spawn"))->get_global_position().x) {
            entity->set_angular_velocity(_DROP_ANGULAR);
            entity->set_linear_velocity(Vector2(-_DROP_VELOCITY.x, _DROP_VELOCITY.y));
        } else {
            entity->set_angular_velocity(-_DROP_ANGULAR);
            entity->set_linear_velocity(_DROP_VELOCITY);
        }

        world->add_child(entity);
    }

    owner->queue_free();
}

void Gun::_process(const float delta) {
    if (_wait_ready > 0) {
        _wait_ready -= delta;
    } else if (_fired) {
        _fired = false;
        _fire_stop();
    }
}
