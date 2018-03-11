#ifndef PISTOL_BULLET_H
#define PISTOL_BULLET_H
#include "bullet.hpp"

class PistolBullet: public Bullet {
    GODOT_CLASS (PistolBullet);

protected:
    void _collision(Variant body);

public:
    PistolBullet();
    ~PistolBullet();

    void _init();
    void _ready();
    void _process(const float delta);
    void damage(Variant d);

    static void _register_methods();
};

#endif
