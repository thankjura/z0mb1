extends Area2D

const constants = preload("res://scripts/constants.gd")
const player = preload("res://scripts/player/player.gd")

export(String, FILE, "*.tscn") var next_scene
export(bool) var confirm

func _ready():
    set_collision_mask(constants.PLAYER_LAYER)
    set_collision_layer(0)
    connect("body_entered", self, "_collision")

func _collision(body):
    if body is player:
        get_tree().set_pause(true)
        scene_switch.change_scene(next_scene, confirm)