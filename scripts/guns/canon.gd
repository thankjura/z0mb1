extends "res://scripts/guns/base.gd"

const BULLET = preload("res://scenes/guns/bullets/canon_fireball.tscn")
const ENTITY = preload("res://scenes/entities/canon_entity.tscn")
const SPEED = 2000
const TIMEOUT = 0.8
const OFFSET = Vector2(-30, 30)
const AIM_NAME = "aim_canon"
const DROP_VELOCITY = Vector2(400,-400)
const DROP_ANGULAR = 1