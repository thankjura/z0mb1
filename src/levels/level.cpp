#include "level.hpp"

Level::Level() {}
Level::~Level() {}

void Level::_init() {}

void Level::_ready() {
    _camera = (Camera2D*) get_node("player/camera");
    
    if (has_node("top_left_limit")) {
        Vector2 tl = ((Node2D*) get_node("top_left_limit"))->get_global_position();
        _camera->set_limit(GlobalConstants::MARGIN_LEFT, tl.x);
        _camera->set_limit(GlobalConstants::MARGIN_TOP, tl.y);
    }
    
    if (has_node("bottom_right_limit")) {
        Vector2 br = ((Node2D*) get_node("bottom_right_limit"))->get_global_position();
        _camera->set_limit(GlobalConstants::MARGIN_RIGHT, br.x);
        _camera->set_limit(GlobalConstants::MARGIN_BOTTOM, br.y);
    }
}
