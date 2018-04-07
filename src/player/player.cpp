#include "player.hpp"

#include <Viewport.hpp>
#include <KinematicCollision2D.hpp>

const Vector2 PlayerHenry::_FLOOR_NORMAL = Vector2(0, -1);
const Vector2 PlayerHenry::_DEFAULT_VECTOR = Vector2(0, -1);
const double PlayerHenry::_SLOPE_FRICTION = 10;
const double PlayerHenry::_MAX_BOUNCES = 4;
const double PlayerHenry::_FLOOR_MAX_ANGLE = 0.8;    
const double PlayerHenry::_RECOIL_DEACCELERATION = 20;

PlayerHenry::PlayerHenry() {
    _health = 200;
    _MAX_JUMP_COUNT = 2;
    _CONTROL_MODE = 1;
    _MAX_FALL_SPEED = 800;    
    _MAX_JUMP_SPEED = 800;
    _AIR_ACCELERATION = 10;
    _GRAVITY = 2000;
    _INIT_JUMP_FORCE = 800;
    _INIT_MAX_SPEED = 400;
    _INIT_MAX_CLIMB_SPEED = 200;
    _INIT_ACCELERATION = 10;
    _DEAD_ZONE_X = 0.1;
    _DEAD_ZONE_Y = 0.1;
    
    _velocity = Vector2();
    _recoil = Vector2();
    
    _is_air_state = false;
    _is_climb_state = false;
    _climb_ladder = NULL;
    _climb_ladder_direction = 0;
    _jump_count = 0;
    
    Vector2 _velocity;
    Vector2 _recoil;
    _gun = NULL;
}

PlayerHenry::~PlayerHenry() {}

void PlayerHenry::_init() {
    _Input = Input::get_singleton();
    
    _ACCELERATION = _INIT_ACCELERATION;
    _MAX_SPEED = _INIT_MAX_SPEED;
    _MAX_CLIMB_SPEED = _INIT_MAX_CLIMB_SPEED;
    _JUMP_FORCE = _INIT_JUMP_FORCE;
}

void PlayerHenry::_ready() {
    set_collision_layer(layers::PLAYER_LAYER);
    set_collision_mask(layers::PLAYER_MASK);
    ((Area2D* ) get_node("base/pelvis/body/head/head_area"))->set_collision_layer(layers::PLAYER_LETHAL_LAYER);
    ((Area2D* ) get_node("base/pelvis/body/head/head_area"))->set_collision_mask(layers::PLAYER_LETHAL_MASK);
    ((Area2D* ) get_node("base/pelvis/body/body_area"))->set_collision_layer(layers::PLAYER_LETHAL_LAYER);
    ((Area2D* ) get_node("base/pelvis/body/body_area"))->set_collision_mask(layers::PLAYER_LETHAL_MASK);
    
    ((Area2D*) get_node("body_area"))->connect("area_entered", this, "_area_entered");
    ((Area2D*) get_node("body_area"))->connect("area_exited", this, "_area_exited");
    Viewport* viewport = get_tree()->get_root();
    _gui = (CanvasLayer*) viewport->get_node("world/gui");
    _update_health(_health);
    
    _camera = as<PlayerCamera>(get_node("camera"));
    _anim = as<PlayerAnim>(get_node("animation_tree_player"));
    _mouth = (Node2D*) get_node("base/pelvis/body/head/mouth");
    _step = (AudioStreamPlayer2D*) get_node("audio_footstep");
    _step_metal = (AudioStreamPlayer2D*) get_node("audio_footstep_metal");
    _step->set_area_mask(layers::AUDIO_AREA_MASK);
    _step_metal->set_area_mask(layers::AUDIO_AREA_MASK);    
}

void PlayerHenry::_area_entered(Variant area) {
    Area2D* a = (Area2D*) get_wrapper<Object>(area.operator godot_object*()); 
    if (a->is_in_group("ladder")) {
        _set_ladder(a);
    }
    
    if (a->is_in_group("camera_zoom")) {
        _camera->area_zoom(a);
    }
}

void PlayerHenry::_area_exited(Variant area) {
    Area2D* a = (Area2D*) get_wrapper<Object>(area.operator godot_object*());
    if (a->is_in_group("ladder")) {
        _set_ladder(NULL);
    }
    
    if (a->is_in_group("camera_zoom")) {
        _camera->reset_zoom();
    }
}

bool PlayerHenry::set_gun(Variant gun_class) {
    if (_gun) {
        return false;
    }
    
    Ref<PackedScene> gun = ResourceLoader::get_singleton()->load(gun_class);
    _gun = as<Gun>(gun->instance());
    get_node("base/pelvis/body/sholder_r/forearm_r/gun_position")->add_child(_gun);    
    _recalc_mass();
    _anim->set_gun(_gun);
    return true;
}

void PlayerHenry::_drop_gun() {
    if (_gun) {
        _gun->drop();
        _anim->drop_gun();
        _recalc_mass();
        _gun = NULL;
    }
}

void PlayerHenry::gun_reload() {
    _anim->gun_reload();
}

void PlayerHenry::damage(const double damage, const Vector2 vector) {
    gun_recoil(vector/10);
    _update_health(_health - damage);
}

void PlayerHenry::_update_health(double new_health) {
    double power = std::min<double>(new_health / _health, 1);
    if (power < 1) {
        _vibrate(0.1, power);
    }
    _health = new_health;
    // TODO: implements gui
    _gui->call("set_health", Array::make(_health));
}

void PlayerHenry::_fire(const double delta) {
    if (not _gun) {
        return;
    }
    _gun->fire(delta, _velocity);
}


void PlayerHenry::set_mouth(String m) {
    Array childs = _mouth->get_children();
    for (int i = 0; i < childs.size(); i++) {
        ((Node2D*) get_wrapper<Object>(childs[i].operator godot_object*()))->set_visible(false);
    }
    if (m == MOUTH_AGGRESIVE) {
        ((Node2D*) _mouth->get_node("mouth_a"))->set_visible(true);
    } else { 
        ((Node2D*) _mouth->get_node("mouth_default"))->set_visible(true);
    }
}

void PlayerHenry::shuffle_camera(const double force, const double fade_out_time) {
    _camera->shuffle_camera(force, fade_out_time);
}

void PlayerHenry::_process(const double delta) {
    if (is_back()) {
        _camera->set_drag_margin(3, 0.1);
        _camera->set_drag_margin(1, 0.3);
    } else {
        _camera->set_drag_margin(3, 0.3);
        _camera->set_drag_margin(1, 0.1);
    }
}

void PlayerHenry::_physics_process(const double delta) {
    if (_Input->is_action_pressed("ui_fire")) {
        _fire(delta);
    }

    if (_Input->is_mouse_button_pressed(GlobalConstants::BUTTON_LEFT)) {
        _fire(delta);
    }
    
    double ratio = NAN;
    if (not _is_climb_state) {        
        if (get_slide_count() > 0) {
            Ref<KinematicCollision2D> c = get_slide_collision(0);
            double a = _FLOOR_NORMAL.angle_to(c->get_normal());
            if (std::abs(a) < _FLOOR_MAX_ANGLE) {
                ratio = a/_ANIM_CLIMB_ANGLE;
            }
        }
        if (ratio == ratio and ratio < 0 and _velocity.x > 0.001) {
            _velocity.y += (_GRAVITY + (_GRAVITY * ratio)) * delta;
        } else {
            _velocity.y += _GRAVITY * delta;
        }
    }
    Vector2 move_vector = _get_move_vector();
    Vector2 direction = _get_direction();

    if (_is_climb_state) {
        _climb_state(delta, move_vector);
    } else {
        if (is_on_floor()) {
            _ground_state(delta, move_vector, ratio);
            if (std::abs(_velocity.x) > _MAX_SPEED) {
                _velocity.x = utils::sign(_velocity.x) * _MAX_SPEED;
            }
        } else {
            _air_state(delta, move_vector);
            if (std::abs(_velocity.x) > _MAX_SPEED) {
                _velocity.x = utils::sign(_velocity.x) * _MAX_SPEED;
            }
        }
        
        if (direction != Vector2()) {
            _look(_DEFAULT_VECTOR.angle_to(direction), delta);
        } else {
            _look_default(delta);
        }

        _velocity.y = utils::clamp(double(_velocity.y), -_MAX_JUMP_SPEED, _MAX_FALL_SPEED);
    }
    
    _velocity = move_and_slide(_velocity + _recoil, _FLOOR_NORMAL, true, _SLOPE_FRICTION, _MAX_BOUNCES, _FLOOR_MAX_ANGLE);
    _velocity -= _recoil;
    
    Vector2 new_recoil = _recoil.linear_interpolate(Vector2(), _RECOIL_DEACCELERATION*delta);
    if (utils::sign(_recoil.x) != utils::sign(new_recoil.x)) {
        new_recoil.x = 0;
    }
    if (utils::sign(_recoil.y) != utils::sign(new_recoil.y)) {
        new_recoil.y = 0;
    }
    _recoil = new_recoil;
}

void PlayerHenry::_register_methods() {
    register_method("_init",                    &PlayerHenry::_init);
    register_method("_ready",                   &PlayerHenry::_ready);
    register_method("_input",                   &PlayerHenry::_input);
    register_method("_process",                 &PlayerHenry::_process);
    register_method("_physics_process",         &PlayerHenry::_physics_process);
    
    register_method("damage",                   &PlayerHenry::damage);
    register_method("_area_entered",            &PlayerHenry::_area_entered);
    register_method("_area_exited",             &PlayerHenry::_area_exited);
    register_method("set_gun",                  &PlayerHenry::set_gun);
    
    register_property("main/health",            &PlayerHenry::_health,                  double(100));
    register_property("main/gravity",           &PlayerHenry::_GRAVITY,                 double(2000));
    register_property("main/jump_force",        &PlayerHenry::_INIT_JUMP_FORCE,         double(800));
    register_property("main/max_speed",         &PlayerHenry::_INIT_MAX_SPEED,          double(400));
    register_property("main/max_climb_speed",   &PlayerHenry::_INIT_MAX_CLIMB_SPEED,    double(200));
    register_property("main/acceleration",      &PlayerHenry::_INIT_ACCELERATION,       double(10));
}


extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *o) {
    Godot::gdnative_init(o);
}

/** GDNative Terminate **/
extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *o) {
    Godot::gdnative_terminate(o);
}

/** NativeScript Initialize **/
extern "C" void GDN_EXPORT godot_nativescript_init(void *handle) {
    Godot::nativescript_init(handle);

    register_class<PlayerAnim>();
    register_class<PlayerCamera>();
    register_class<PlayerHenry>();
}
