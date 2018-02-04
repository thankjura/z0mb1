extends "res://scripts/main/base_menu.gd"
const PARENT_MENU = null

func _on_resume_pressed():
    global.resume()

func _on_settings_pressed():
    global.show_menu("settings")

func _on_main_menu_pressed():
    global.save_and_exit()