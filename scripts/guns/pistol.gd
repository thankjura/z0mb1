extends "res://scripts/guns/base.gd"

const BULLET = preload("res://scenes/guns/bullets/fireball.tscn")
const ENTITY = preload("res://scenes/entities/pistol_entity.tscn")
const SPEED = 2000
const TIMEOUT = 0.4
const OFFSET = Vector2(45, -39)
const DROP_VELOCITY = Vector2(300,-300)
const DROP_ANGULAR = 20
const AIM_NAME = "aim_pistol"

func _muzzle_flash():
    $animation_player.play("fire%d" % (randi()%2+1), -1, 2)

func _eject_shell():
    $shell_particles.restart()