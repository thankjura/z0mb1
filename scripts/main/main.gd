extends Node2D

const SELECTED_COLOR = Color(1, 0, 0)

const CONTINUE = "continue"
const NEW_GAME = "new_game"
const PREFERENCES = "preferences"
const QUIT = "quit"

const MENU_ITEMS = [NEW_GAME, PREFERENCES, QUIT]

var selected_item
var global

func _ready():
    global = get_node("/root/global")
    
    if not "continue" in MENU_ITEMS:
        get_node("menu_bg/menu_items/continue").set("custom_colors/font_color", Color(0.7, 0.7, 0.7))
        get_node("menu_bg/menu_items/continue").set("custom_colors/font_color_shadow", Color(0.5, 0.5, 0.5))
    
func _select_item(item_name):
    for i in MENU_ITEMS:
        if i == item_name:
            get_node("menu_bg/menu_items/" + i).set("custom_colors/font_color", SELECTED_COLOR)
            selected_item = item_name
        else:
            get_node("menu_bg/menu_items/" + i).set("custom_colors/font_color", null)
    $menu_tap.play()

func _enter_item():
    if selected_item == NEW_GAME:
        scene_switch.fade_to("res://levels/intro.tscn")

func _input(event):
    if event.is_action_pressed("ui_up"):
        _ui_up()

    if event.is_action_released("ui_down"):
        _ui_down()
        
    if event.is_action_released("ui_accept"):
        _enter_item()

func _ui_up():
    if not selected_item:
        _select_item(MENU_ITEMS[0])
    else:
        var idx = MENU_ITEMS.find(selected_item)
        if idx == -1:
            _select_item(MENU_ITEMS[0])
        else:
            idx -= 1
            if idx < 0:
                idx = MENU_ITEMS.size() - 1
        _select_item(MENU_ITEMS[idx])
        
func _ui_down():
    if not selected_item:
        _select_item(MENU_ITEMS[0])
    else:
        var idx = MENU_ITEMS.find(selected_item)
        if idx == -1:
            _select_item(MENU_ITEMS[0])
        else:
            idx += 1
            if idx >= MENU_ITEMS.size():
                idx = 0
        _select_item(MENU_ITEMS[idx])