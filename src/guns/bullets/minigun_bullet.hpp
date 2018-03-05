#ifndef MINIGUN_BULLET_H
#define MINIGUN_BULLET_H
#include "bullet.hpp"

class MinigunBullet: public Bullet {
    GODOT_CLASS (MinigunBullet);

protected:
    void _collision(Variant body);

public:
    MinigunBullet();
    ~MinigunBullet();

    void _init();
    void _ready();
    void _process(const float delta);
    void damage(Variant d);
    int get_damage();

    static void _register_methods();
};

#endif
