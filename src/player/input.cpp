#include "player.hpp"
#include <InputEventMouseButton.hpp>

void PlayerHenry::_input(const Ref<InputEvent> event) {
    if (event->is_action_pressed("ui_jump")) {
        _jump();
    }
    if (event->is_action_released("ui_drop")) {
        _drop_gun();
    }
    InputEventMouseButton* mb = Object::cast_to<InputEventMouseButton>(event.ptr());
    if (mb) {
        const double idx = mb->get_button_index();        
        if (idx == GlobalConstants::BUTTON_RIGHT and mb->is_pressed()) {
            _jump();
        }
    }
}

Vector2 PlayerHenry::_get_move_vector() {
    int up = _Input->is_action_pressed("ui_up") ? -1 : 0;
    int down = _Input->is_action_pressed("ui_down") ? 1 : 0;
    int left = _Input->is_action_pressed("ui_left") ? -1 : 0;
    int right = _Input->is_action_pressed("ui_right") ? 1 : 0;

    Vector2 out = Vector2(left+right, up+down);
    
    double axis_x = _Input->get_joy_axis(GAMEPAD_ID, GlobalConstants::JOY_AXIS_0);
    double axis_y = _Input->get_joy_axis(GAMEPAD_ID, GlobalConstants::JOY_AXIS_1);

    if (std::abs(axis_x) > _DEAD_ZONE_X) {
        out.x += axis_x;
    }

    if (std::abs(axis_y) > _DEAD_ZONE_Y) {
        out.y += axis_y;
    }

    return out.normalized();
}

Vector2 PlayerHenry::_get_direction() {
    Vector2 direction = Vector2();
    if (_gun) {
        Node2D* pos = (Node2D*) _gun->get_node("pos");
        direction = (get_global_mouse_position() - pos->get_global_position()).normalized();
        double dist = std::abs((get_global_position().x - get_global_mouse_position().x));
        if (get_global_mouse_position().y > pos->get_global_position().y) {
            if (dist < _gun->get_dead_zone_bottom()) {
                direction.x = 0;
            }
        } else {
            if (dist < _gun->get_dead_zone_top()) {
                direction.x = 0;
            }
        }
    } else {
        direction = get_global_mouse_position() - get_global_position();
    }
    return direction;
}

void PlayerHenry::_vibrate(const double time, const double weak, const double strong, const double duration) {
    if (_Input->is_joy_known(GAMEPAD_ID)) {
       _Input->start_joy_vibration(GAMEPAD_ID, weak, strong, duration);
    }
}
