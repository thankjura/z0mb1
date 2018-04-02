#ifndef SHELL_H
#define SHELL_H
#include <core/Godot.hpp>
#include <RigidBody2D.hpp>

#include "../../constants.hpp"

using namespace godot;

class Shell: public RigidBody2D {
    GODOT_CLASS (Shell, RigidBody2D);

private:
    double _timer;

public:
    double _TIMEOUT;

    Shell();
    ~Shell();

    void _init();
    void _ready();
    void _process(const double delta);

    static void _register_methods();
};

#endif
