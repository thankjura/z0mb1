extends "res://scripts/guns/base.gd"

const fireball = preload("res://scenes/guns/bullets/canon_fireball.tscn")
const gun_entity = preload("res://scenes/entities/canon_entity.tscn")
const SPEED = 20
const TIMEOUT = 0.8
const OFFSET = Vector2(-30, 30)
const GUN_CLASS = "canon"

func _drop():
    var entity = gun_entity.instance()
    entity.set_global_position(global_position)
    if $from.global_position.x <= $to.global_position.x:
        entity.set_angular_velocity(1)
        entity.set_linear_velocity(Vector2(-400,-400))
    else:
        entity.set_angular_velocity(-1)
        entity.set_linear_velocity(Vector2(400,-400))
    var world = get_tree().get_root().get_node("world")
    world.add_child(entity)
    queue_free()