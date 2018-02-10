extends "res://scripts/main/base_menu.gd"
const PARENT_MENU = "settings"

func _ready():
    $panel/items/music_volume.set_value(global.SETTINGS.music_volume)
    $panel/items/effects_volume.set_value(global.SETTINGS.effects_volume)

func _on_back_pressed():
    global.go_back()

func _on_save_pressed():
    global.SETTINGS.set_music_volume($panel/items/music_volume.value)
    global.SETTINGS.set_effects_volume($panel/items/effects_volume.value)
    global.SETTINGS.apply_sound_settings()
    global.SETTINGS.save()