extends Node

const SCENES = {
    "intro": "res://levels/intro.tscn"
}


func load_scene(scene):
    get_tree().chacnge_scene(SCENES[scene])