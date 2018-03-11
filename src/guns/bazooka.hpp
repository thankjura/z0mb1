#ifndef BAZOOKA_H
#define BAZOOKA_H
#include "gun.hpp"

class Bazooka: public Gun {
    GODOT_CLASS (Bazooka);

private:
    float _wait_for_reload;
    void _reload();

public:
    Bazooka();
    ~Bazooka();

    void default_offset();
    void climb_offset();
    void drop();
    void fire(const float delta, const Vector2 velocity);

    void _init();
    void _ready();
    void _process(const float delta);
    static void _register_methods();
};

#endif