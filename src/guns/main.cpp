#include <core/Godot.hpp>
#include "ak47.hpp"
#include "bazooka.hpp"
#include "minigun.hpp"
#include "pistol.hpp"
#include "shotgun.hpp"

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

    register_class<AK47Gun>();
    register_class<Bazooka>();
    register_class<Minigun>();
    register_class<Pistol>();
    register_class<Shotgun>();
}
