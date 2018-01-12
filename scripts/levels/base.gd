extends Node

const utils = preload("res://scripts/utils/utils.gd")

func _ready():
    if has_node("top_left_limit"):
        var tl = $top_left_limit.global_position
        get_node("player/camera").limit_left = tl.x
        get_node("player/camera").limit_top = tl.y
    if has_node("bottom_right_limit"):
        var br = $bottom_right_limit.global_position
        get_node("player/camera").limit_right = br.x
        get_node("player/camera").limit_bottom = br.y