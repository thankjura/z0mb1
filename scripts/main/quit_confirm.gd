extends "res://scripts/main/base_menu.gd"

const INIT_ITEM = "panel/items/cancel"

func _ready():
    selected_item.grab_focus()

func _on_quit_pressed():
    get_tree().quit()


func _on_cancel_pressed():
    queue_free()
