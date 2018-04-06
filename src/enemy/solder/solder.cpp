#include "solder.hpp"
#include "../../constants.hpp"
#include <SceneTree.hpp>

EnemySolder::EnemySolder():Enemy() {
    _ATTACK_DISTANCE = 800;
    _ATTACK_DAMAGE = 30;
    _BACKSLIDE_DISTANCE = 50;
    _MAX_SPEED = 100;
    _MAX_RUN_SPEED = 150;
    _MAX_JUMP = 600;
    _ACCELERATION = 10;
    _AIM_TIME = 3;
    
    _DEFAULT_VECTOR = Vector2(0, -1);
    _BULLET_SPEED = 20000;
    _BODY_STRENGTH = 120;
    _HEAD_STRENGTH = 100;
    
    _direction = 1;
    _current_state = SOLDER_WALK;
    _switch_state_timeout = 0;
    _jump_vector = Vector2();
    _aim_timeout = 0;
    _health = 100;
    _dead = false;
}

EnemySolder::~EnemySolder() {}

void EnemySolder::_init() {
    Enemy::_init();
}

void EnemySolder::_ready() {
    Enemy::_ready();
    _BULLET = ResourceLoader::get_singleton()->load("res://scenes/enemy/bullets/enemy_pistol_bullet.tscn");
    _animation = as<SolderAnim>(get_node("anim"));
    _audio_fire = (AudioStreamPlayer2D*) get_node("audio_fire");

    _body_area = (Area2D*) get_node("base/base/body/body_area");
    _head_area = (Area2D*) get_node("base/base/body/head/head_area");
    
    _base = (Node2D*) get_node("base");
    _bullet_position = (Node2D*) get_node("base/base/body/sholder_l/forearm_l/hand_l_pistol/pistol/from");
    _body_area->set_collision_layer(layers::ENEMY_DAMAGE_LAYER);
    _body_area->set_collision_mask(layers::ENEMY_DAMAGE_MASK);
    _head_area->set_collision_layer(layers::ENEMY_DAMAGE_LAYER);
    _head_area->set_collision_mask(layers::ENEMY_DAMAGE_MASK);
    
    _bullet_spawn = (Node2D*) get_node("base/base/body/sholder_l/forearm_l/hand_l_pistol/pistol/bullet_spawn");
    _world = (Node2D*) get_tree()->get_current_scene();
    _ray_bottom = (RayCast2D*) get_node("base/base/ray_cast_bottom");
    _ray_middle = (RayCast2D*) get_node("base/base/ray_cast_middle");
    _ray_height = (RayCast2D*) get_node("base/base/ray_cast_height");    
    _eyes = (RayCast2D*) get_node("base/base/ray_cast_eyes");
    
    _eyes->set_collision_mask(layers::ENEMY_SEE_MASK);
    _eyes->set_cast_to(Vector2(_ATTACK_DISTANCE/get_scale().x, 0));
    
    _body_area->connect("body_entered", this, "_body_hit");
    _head_area->connect("body_entered", this, "_head_hit");
    
    if (_direction != _base->get_scale().x) {
        _direction = -_direction;
        _set_direction(-_direction);
    }
    _next_direction = _direction;
    _next_state = _current_state;
}

void EnemySolder::_body_hit(Object* obj) {
    if (obj->has_method("damage")) {
        obj->call("damage", Array::make(_BODY_STRENGTH));
    }
    
    if (obj->has_method("get_damage")) {
        _health -= (double) obj->call("get_damage");
        if (_health > 0) {
            RigidBody2D* r = Object::cast_to<RigidBody2D>(obj);
            if (r) {
                _animation->hit_body(r->get_linear_velocity());
            }
        }
    }
}

void EnemySolder::_head_hit(Object* obj) {
    if (obj->has_method("damage")) {
        obj->call("damage", Array::make(_HEAD_STRENGTH));
    }
    
    if (obj->has_method("get_damage")) {
        _health -= ((double) obj->call("get_damage")) * 2;        
        if (_health > 0) {
            RigidBody2D* r = Object::cast_to<RigidBody2D>(obj);
            if (r) {
                _animation->hit_head(r->get_linear_velocity());
            }
        }
    }
}

void EnemySolder::_set_direction(const int direction) {    
    if (_direction != direction) {
        _direction = direction;
        if (_direction == -1) {
            _base->set_scale(Vector2(-1,1));
        } else if (_direction == 1) {
            _base->set_scale(Vector2(1,1));
        }
    }
}

int EnemySolder::_get_direction() {
    return _base->get_scale().x;
}

void EnemySolder::_fire() {
    RigidBody2D* b = (RigidBody2D*) _BULLET->instance();
    
    Vector2 bullet_velocity = (_bullet_spawn->get_global_position() - _bullet_position->get_global_position()).normalized();
    double gun_angle = Vector2(1, 0).angle_to(bullet_velocity);

    b->rotate(gun_angle);
    b->set_axis_velocity(bullet_velocity * _BULLET_SPEED + _velocity);
    b->set_global_position(_bullet_spawn->get_global_position());
    _world->add_child(b);
    _audio_fire->play();
}

void EnemySolder::_aim(const double delta) {
    Vector2 v = (((Node2D*)_player->get_node("aim"))->get_global_position() - _bullet_spawn->get_global_position()).normalized();
    _animation->aim(utils::rad2deg(_DEFAULT_VECTOR.angle_to(v)), delta);
}

void EnemySolder::change_direction(const double t, const int direction) {
    _current_state = SOLDER_IDLE;
    _switch_state_timeout = t;
    _next_direction = direction;    
}

void EnemySolder::die() {
    Enemy::die();
    _body_area->disconnect("body_entered", this, "_body_hit");
    _head_area->disconnect("body_entered", this, "_head_hit");
    _animation->die();
}

void EnemySolder::_init_jump(const double height) {
    _switch_state_timeout = 10;
    _current_state = SOLDER_PREJUMP;
    _next_state = SOLDER_PREJUMP;
    _jump_vector = Vector2(200*_direction, -height * 1.8);
    _animation->init_jump();
}

void EnemySolder::_start_jump() {
    _animation->pause_jump();
    _velocity += _jump_vector;
    _current_state = SOLDER_JUMP;
    _next_state = SOLDER_WALK;
}

void EnemySolder::_end_jump() {
    _switch_state_timeout = 0;
    _next_state = SOLDER_WALK;
}

bool EnemySolder::_is_player_visible() {
    _eyes->look_at(((Node2D*) _player->get_node("aim"))->get_global_position());
    if (_eyes->is_colliding()) {
        CanvasItem* o = (CanvasItem*) _eyes->get_collider();
        if (o->get_name() == "player" or o->get_owner()->get_name() == "player") {
            return true;
        }
    }
    return false;
}

void EnemySolder::_process(const double delta) {
    Enemy::_process(delta);
    if (_dead) {
        return;
    }

    if (_current_state != _next_state) {    
        _switch_state_timeout -= delta;
        if (_switch_state_timeout < 0) {
            _current_state = _next_state;
            _set_direction(_next_direction);
        }
    }
        
    bool check_attacking = false;

    if (_current_state != SOLDER_JUMP) {
        if (_player->get_global_position().x > get_global_position().x) {
            if (_base->get_scale().x == 1) {
                check_attacking = true;
            }
        } else {
            if (_base->get_scale().x == -1) {
                check_attacking = true;
            }
        }
    }
    
    if (check_attacking and _is_player_visible()) {
        if (_current_state != SOLDER_AIM) {
            _current_state = SOLDER_AIM;
            _next_state = SOLDER_WALK;
            _aim_timeout = _AIM_TIME;
            _animation->idle();
        }
        _switch_state_timeout = _AIM_TIME;
    }
    
    if (_current_state == SOLDER_AIM) {
        if (_aim_timeout <= 0) {
            _fire();
            _aim_timeout = _AIM_TIME;
        } else {
            _aim_timeout -= delta;
        }
    }
    
    if (_current_state == SOLDER_JUMP and is_on_floor() and _velocity.y == 0) {
        _current_state = SOLDER_IDLE;
        _next_state = SOLDER_WALK;
        _switch_state_timeout = 0.2;
        _animation->play_jump();
    }

    if (_current_state == SOLDER_WALK and is_on_floor() and (_ray_bottom->is_colliding() or _ray_middle->is_colliding())) {
        Vector2 p = _ray_height->get_collision_point();
        double h = _ray_height->get_cast_to().y - (p.y - _ray_height->get_global_position().y);
        if (h < _MAX_JUMP) {
            _init_jump(h);
        } else {
            change_direction(1, -_direction);
        }
    }
}

void EnemySolder::_physics_process(const double delta) {
    Enemy::_physics_process(delta);
    if (_dead) {
        return;
    }

    if (_current_state == SOLDER_WALK) {
        _velocity.x = utils::lerp(_velocity.x, _MAX_SPEED * _direction, _ACCELERATION*delta);
    } else if (_current_state == SOLDER_JUMP) {
        _velocity.x = utils::lerp(_velocity.x, _jump_vector.x, _ACCELERATION*delta);
    } else {
        _velocity.x = utils::lerp(_velocity.x, 0, _ACCELERATION*delta);
    }

    if (_current_state == SOLDER_AIM) {
        if (_player->get_global_position().x > get_global_position().x) {
            _set_direction(1);
        } else {
            _set_direction(-1);
        }
        _aim(delta);
    } else {
        if (is_on_floor()) {
            _animation->walk(std::abs(_velocity.x) * delta);
        }
    }
}

void EnemySolder::_register_methods() {
    register_method("_init",                                        &EnemySolder::_init);
    register_method("_ready",                                       &EnemySolder::_ready);
    register_method("_process",                                     &EnemySolder::_process);
    register_method("_physics_process",                             &EnemySolder::_physics_process);
    
    register_method("change_direction",                             &EnemySolder::change_direction);
    register_method("die",                                          &EnemySolder::die);
    register_method("_body_hit",                                    &EnemySolder::_body_hit);
    register_method("_head_hit",                                    &EnemySolder::_head_hit);
        
    register_property<EnemySolder, double>("main/health",           &EnemySolder::_health,                  double(100));
    register_property<EnemySolder, double>("main/gravity",          &EnemySolder::_GRAVITY,                 double(2000));
    register_property<EnemySolder, int>   ("main/init_direction",   &EnemySolder::_direction,               int(1));
}
