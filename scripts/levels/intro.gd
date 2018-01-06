extends "res://scripts/levels/base.gd"

const ENEMY_COUNT = 30
const ENEMY_EMMIT_ACCELERATION = 1

const yellow_eyes = preload("res://scenes/enemy/yellow_eyes.tscn")
const ENEMIES = [yellow_eyes]

var MAX_ENEMY = 10

func _ready():
    var positions = $zombie_source.get_children()
    for p in positions:
        p.set_meta("free", true)

func _process1(delta):
    if get_tree().get_nodes_in_group("enemy").size() < MAX_ENEMY:
        _add_enemy(delta)

func _add_enemy(delta):
    var params = {"free": true}
    var pos = utils.get_random_with_meta($zombie_source.get_children(), params)
    if not pos:
        return
    pos.set_meta("free", false)
    var ec = ENEMIES[randi()%ENEMIES.size()]
    var e = ec.instance()
    e.set_global_position(pos.global_position)
    e.add_to_group("enemy")
    e.set_light_mask(16)
    add_child(e)
    e.init_from_hole(pos)

