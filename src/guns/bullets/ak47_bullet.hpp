#ifndef AK47_BULLET_H
#define AK47_BULLET_H
#include "bullet.hpp"

class AK47Bullet: public Bullet {
    GODOT_CLASS (AK47Bullet);

protected:
    void _collision(Variant body);

public:
    AK47Bullet();
    ~AK47Bullet();

    void _init();
    void _ready();
    void _process(const float delta);
    void damage(Variant d);

    static void _register_methods();
};

#endif
