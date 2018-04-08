#ifndef LEVEL_INTRO_H
#define LEVEL_INTRO_H
#include "../level.hpp"

class LevelIntro: public Level {

public:    
    LevelIntro();
    ~LevelIntro();

    void _init();
    void _ready();    
    
    static void _register_methods();
};

#endif