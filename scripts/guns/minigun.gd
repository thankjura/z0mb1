extends "res://scripts/guns/base.gd"

const BULLET = preload("res://scenes/guns/bullets/minigun_bullet.tscn")
const ENTITY = preload("res://scenes/entities/minigun_entity.tscn")
const SPEED = 5000
const TIMEOUT = 0.1
const OFFSET = Vector2(40, -10)
const GUN_CLASS = "minigun"

func _muzzle_flash(delta):
    return

func _fire_start(delta):
    $case_particles.set_emitting(true)
    $anim.play("fire")

func _fire_stop(delta):
    $case_particles.set_emitting(false)
    $anim.stop()
    $flash.set_visible(false)