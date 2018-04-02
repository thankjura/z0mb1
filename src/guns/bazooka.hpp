#ifndef BAZOOKA_H
#define BAZOOKA_H
#include "gun.hpp"

class Bazooka: public Gun {
    GODOT_CLASS (Bazooka, Node2D);

private:
    double _wait_for_reload;
    void _reload();

public:
    Bazooka();
    ~Bazooka();

    void _init();
    void _ready();
    void _process(const double delta);
    static void _register_methods();
};

#endif