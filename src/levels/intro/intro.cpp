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
