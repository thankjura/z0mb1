extends Node2D

var selected_item
var global

func _ready():
    global = get_node("/root/global")
    get_node("menu_items/continue").set_disabled(true)
    get_node("menu_items/new_game").grab_focus()

    for i in get_node("menu_items").get_children():
        i.connect("focus_entered", self, "_focus_item", [i])
        i.connect("mouse_entered", self, "_mouse_item", [i])
        i.set_default_cursor_shape(Control.CURSOR_POINTING_HAND)

    print("ready")

func _focus_item(i):
    $menu_tap.play()

func _mouse_item(i):
    i.grab_focus()

func _on_continue_pressed():
    print("continue")

func _on_new_game_pressed():
    print("new game")
    $menu_enter.play()
    global.new_game()

func _on_quit_pressed():
    global.show_menu("quit")

func _on_settings_pressed():
    global.show_menu("settings")


