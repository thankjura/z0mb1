const CONFIG_PATH = "user://settings.cfg"
var config

enum INPUT_MODELS {
    GAMEPAD_SIMPLE,
    GAMEPAD,
    KEYBOARD,
    KEYBOARD_MOUSE
}

var input_model = 0
var music_volume = 100
var effects_volume = 100

var config_changed = false

func _init():
    config = ConfigFile.new()
    var err = config.load(CONFIG_PATH)
    apply_input_settings()
    apply_sound_settings()
    if config_changed:
        save()

func apply_input_settings():
    input_model = config.get_value("input", "input_model", input_model)
    if not input_model in INPUT_MODELS.keys():
        input_model = 0
        config.set_value("input", "input_model", 0)
        config_changed = true

func apply_sound_settings():
    music_volume = config.get_value("sound", "music_volume", music_volume)
    if music_volume < 0 or music_volume > 100:
        set_music_volume(100)
        config_changed = true
    effects_volume = config.get_value("sound", "effects_volume", effects_volume)
    if effects_volume < 0 or effects_volume > 100:
        set_effects_volume(100)
        config_changed = true
    AudioServer.set_bus_volume_db(0, linear2db(effects_volume/100.0))

func set_music_volume(vol):
    music_volume = vol
    config.set_value("sound", "music_volume", vol)

func set_effects_volume(vol):
    effects_volume = vol
    config.set_value("sound", "effects_volume", vol)

func save():
    config.save(CONFIG_PATH)
    config_changed = false