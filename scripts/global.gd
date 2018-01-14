extends Node

var MAIN_SCENE = "res://scenes/main/main.tscn"

var GAME_MENU = preload("res://scenes/main/game_menu.tscn")
var QUIT_CONFIRM = preload("res://scenes/main/quit_confirm.tscn")

var current_menu

const LEVELS = {
    "intro": "res://levels/intro.tscn"
}

func _ready():
    set_pause_mode(PAUSE_MODE_PROCESS)

func resume():
    get_tree().set_pause(false)
    current_menu = null

func main_menu():
    get_tree().set_pause(false)
    current_menu = null
    scene_switch.simple(MAIN_SCENE)

func new_game():
    scene_switch.simple(LEVELS.intro)

func settings():
    pass

func quit_confirm():
    current_menu = QUIT_CONFIRM.instance()
    get_tree().get_root().add_child(current_menu)

func _input(event):
    if event.is_action_released("ui_cancel"):
        if current_menu:
            if current_menu.get_filename() == GAME_MENU.get_path():
                current_menu.queue_free()
                resume()
            elif current_menu.get_filename() == QUIT_CONFIRM.get_path():
                current_menu.queue_free()
                current_menu = null
        else:
            if get_tree().get_current_scene().get_filename() in LEVELS.values():
                get_tree().set_pause(true)
                current_menu = GAME_MENU.instance()
                get_tree().get_root().add_child(current_menu)
            elif get_tree().get_current_scene().get_filename() == MAIN_SCENE:
                quit_confirm()