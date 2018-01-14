extends "res://scripts/main/base_menu.gd"

func _on_resume_pressed():
    global.resume()
    queue_free()

func _on_settings_pressed():
    pass # replace with function body

func _on_main_menu_pressed():
    global.main_menu()
    queue_free()
