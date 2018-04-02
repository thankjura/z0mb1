#include "player.hpp"

void PlayerHenry::_footstep(const double ratio) {
    double vol = utils::linear2db(_FOOT_STEP_LEN*ratio);
    _step->set_volume_db(vol);
    _step->play();
}

void PlayerHenry::_footstep_metal(const double ratio) {
    double vol = utils::linear2db(_FOOT_STEP_LEN*ratio);
    _step_metal->set_volume_db(vol);
    _step_metal->play();
}

void PlayerHenry::_footstep_sound() {
    if (_is_climb_state) {
        double ratio = std::abs(_velocity.y)/_MAX_CLIMB_SPEED;
        _footstep(ratio);
    } else {
        double ratio = std::abs(_velocity.x)/_MAX_SPEED;
        _footstep(ratio);
    }
}
