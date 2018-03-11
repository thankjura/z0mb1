#ifndef SHELL_H
#define SHELL_H
#include <core/Godot.hpp>
#include <RigidBody2D.hpp>

#include "../../constants.hpp"

using namespace godot;

class Shell: public GodotScript<RigidBody2D> {
    GODOT_CLASS (Shell);

private:
    float _timer;

public:
    float _TIMEOUT;

    Shell();
    ~Shell();

    void _init();
    void _ready();
    void _process(const float delta);

    static void _register_methods();
};

#endif
