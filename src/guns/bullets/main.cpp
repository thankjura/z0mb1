#include <core/Godot.hpp>
#include "ak47_bullet.hpp"
#include "bazooka_rocket.hpp"
#include "minigun_bullet.hpp"
#include "pistol_bullet.hpp"
#include "shotgun_pellet.hpp"

using namespace godot;

extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *o) {
    Godot::gdnative_init(o);
}

/** GDNative Terminate **/
extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *o) {
    Godot::gdnative_terminate(o);
}

/** NativeScript Initialize **/
extern "C" void GDN_EXPORT godot_nativescript_init(void *handle) {
    Godot::nativescript_init(handle);

    register_class<AK47Bullet>();
    register_class<BazookaRocket>();
    register_class<MinigunBullet>();
    register_class<PistolBullet>();
    register_class<ShotgunPellet>();
}
