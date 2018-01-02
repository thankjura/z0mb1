extends "res://scripts/guns/base.gd"

const BULLET = preload("res://scenes/guns/bullets/fireball.tscn")
const ENTITY = preload("res://scenes/entities/r8_entity.tscn")
const SPEED = 2000
const TIMEOUT = 0.2
const OFFSET = Vector2(40, -10)
const DROP_VELOCITY = Vector2(300,-300)
const DROP_ANGULAR = 20
const AIM_NAME = "aim_pistol"