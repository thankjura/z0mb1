extends "res://scripts/main/base_menu.gd"

func _on_control_pressed():
    pass # replace with function body


func _on_sound_pressed():
    global.show_menu("sound_settings")


func _on_display_pressed():
    pass # replace with function body


func _on_back_pressed():
    global.go_back()
