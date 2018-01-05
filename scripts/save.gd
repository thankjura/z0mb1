extends Node

const MAX_SLOTS = 3

var slots = {}

var slot = 0

const slot_template = {
    "score": 0,
    "lives": 0,
    "health": 0
}

func _ready():
    var save_dir = Directory.new()
    if !save_dir.dir_exists("user://saves"):
        save_dir.open("user://")
        save_dir.make_dir("user://saves")
    save_dir.open("user://save")
    for i in MAX_SLOTS:
        var f = File.new()
        var path = _get_slot_path(i)
        f.open_encrypted_with_pass(path, f.READ, path)
        slots[i] = parse_json(f.get_as_text())

func _get_slot_path(slot_num):
    return "user://saves/slot%02d.save" % slot_num

func load_game(slot_num):
    slot = slot_num

func save_game():
    var f = File.new()
    var path = _get_slot_path(slot)
    f.open_encrypted_with_pass(path, f.WRITE, path)
    
    var data = slot_template.duplicate()
    data.health = 100
    data.lives = 3
    data.score = 9999
    
    f.store_string(to_json(data))
    f.close()
    
    