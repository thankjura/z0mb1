extends Node

var MAIN_SCENE = "res://scenes/main/main.tscn"

var GAME_MENU = preload("res://scenes/main/game_menu.tscn")
var SETTINGS_MENU = preload("res://scenes/main/settings_menu.tscn")
var QUIT_CONFIRM = preload("res://scenes/main/quit_confirm.tscn")

var MENU_SCENES = {
    "main": GAME_MENU,
    "settings": SETTINGS_MENU,
    "quit": QUIT_CONFIRM
}

var current_menu

const LEVELS = {
    "intro": "res://levels/intro.tscn"
}

func _ready():
    set_pause_mode(PAUSE_MODE_PROCESS)

func new_game():
    scene_switch.change_scene(LEVELS.intro)

func resume():
    if current_menu:
        current_menu.queue_free()
        current_menu = null
    get_tree().set_pause(false)

func save_and_exit():
    if current_menu:
        current_menu.queue_free()
        current_menu = null
    scene_switch.change_scene(MAIN_SCENE, false)

func show_menu(menu_name):
    if current_menu:
        current_menu.queue_free()
    current_menu = MENU_SCENES[menu_name].instance()
    get_tree().get_root().add_child(current_menu)

func go_back():
    if current_menu:
        var parent_name = current_menu.PARENT_MENU
        if parent_name:
            show_menu(current_menu.PARENT_MENU)
        else:
            resume()

func _input(event):
    if event.is_action_released("ui_esc"):
        if current_menu:
            go_back()
        else:
            var wr = weakref(get_tree().get_current_scene())
            if wr.get_ref() != null:
                var scene = wr.get_ref()
                if scene.get_filename() in LEVELS.values():
                    get_tree().set_pause(true)
                    show_menu("main")
                elif scene.get_filename() == MAIN_SCENE:
                    show_menu("quit")