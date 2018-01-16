extends "res://scripts/guns/base.gd"

const BULLET = preload("res://scenes/guns/bullets/pistol_bullet.tscn")
const SHELL = preload("res://scenes/guns/shells/pistol_shell.tscn")
const ENTITY = preload("res://scenes/entities/pistol_entity.tscn")
const SPEED = 1200
const TIMEOUT = 0.4
const OFFSET = Vector2(45, -39)
const AIM_NAME = "aim_pistol"
const VIEWPORT_SHUTTER = 0
const DROP_VELOCITY = Vector2(300,-300)
const DROP_ANGULAR = 20
const RECOIL = Vector2(0, 0)
const SPREADING = 0.01
const EJECT_SHELL_VECTOR = Vector2(0, -200)

const ANIM_DEAD_ZONE_BOTTOM = 40

func _muzzle_flash():
    $animation_player.play("fire%d" % (randi()%2+1), -1, 2)