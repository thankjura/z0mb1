#include "shell.hpp"

Shell::Shell() {}

Shell::~Shell() {}

void Shell::_init() {}

void Shell::_ready() {
    set_collision_layer(layers::BULLET_SHELL_LAYER);
    set_collision_mask(layers::BULLET_SHELL_MASK);
    _timer = _TIMEOUT;
}

void Shell::_process(const double delta) {
    _timer -= delta;
    if (_timer <= 0) {
        queue_free();
    }
}

void Shell::_register_methods() {
    register_method ("_init", &Shell::_init);
    register_method ("_ready", &Shell::_ready);
    register_method ("_process", &Shell::_process);
    register_property<Shell, double> ("timeout", &Shell::_TIMEOUT, double(5.0));
}
