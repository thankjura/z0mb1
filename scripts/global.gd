extends Node

var GAME_MENU = preload("res://scenes/main/game_menu.tscn")

var current_menu

const SCENES = {
    "intro": "res://levels/intro.tscn"
}

func _ready():
    set_pause_mode(PAUSE_MODE_PROCESS)

func load_scene(scene):
    get_tree().change_scene(SCENES[scene])

func resume():
    get_tree().set_pause(false)
    current_menu = null

func _input(event):
    if current_menu:
        if event.is_action_released("ui_cancel"):
            current_menu.queue_free()
            resume()
    else:
        if event.is_action_released("ui_cancel"):
            if get_tree().get_current_scene().get_filename() in SCENES.values():
                get_tree().set_pause(true)
                current_menu = GAME_MENU.instance()
                get_tree().get_root().add_child(current_menu)