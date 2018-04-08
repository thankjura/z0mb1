#include "intro.hpp"

LevelIntro::LevelIntro():Level() {}
LevelIntro::~LevelIntro() {}

void LevelIntro::_init() {
    Level::_init();
}

void LevelIntro::_ready() {
    Level::_ready();
}

void LevelIntro::_register_methods() {
    register_method("_init",                   &LevelIntro::_init);
    register_method("_ready",                  &LevelIntro::_ready);
}

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

    register_class<LevelIntro>();
}
