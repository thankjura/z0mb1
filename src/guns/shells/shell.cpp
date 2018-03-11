#include "shell.hpp"

Shell::Shell() {}

Shell::~Shell() {}

void Shell::_init() {}

void Shell::_ready() {
    owner->set_collision_layer(layers::BULLET_SHELL_LAYER);
    owner->set_collision_mask(layers::BULLET_SHELL_MASK);
    _timer = _TIMEOUT;
}

void Shell::_process(const float delta) {
    _timer -= delta;
    if (_timer <= 0) {
        owner->queue_free();
    }
}

void Shell::_register_methods() {
    register_method ((char *) "_init", &Shell::_init);
    register_method ((char *) "_ready", &Shell::_ready);
    register_method ((char *) "_process", &Shell::_process);
    register_property ((char *) "timeout", &Shell::_TIMEOUT, float(5.0));
}
