extends Node2D

const FADE_TIME = 0.3
const constants = preload("res://scripts/constants.gd")
const player = preload("res://scripts/player/player.gd")

var show = false
var fade_timeout = 0

func _ready():
    $inner_area.set_collision_layer(constants.AUDIO_AREA_MASK)
    $inner_area.set_collision_mask(constants.PLAYER_LAYER)
    $inner_area.connect("body_entered", self, "_show")
    $inner_area.connect("body_exited", self, "_hide")
    $static_truck.set_collision_mask(0)
    $static_truck.set_collision_layer(constants.GROUND_LAYER)

func _show(body):
    if body is player:
        if not show:
            fade_timeout = FADE_TIME - fade_timeout
            show = true

func _hide(body):
    if body is player:
        if show:
            fade_timeout = FADE_TIME - fade_timeout
            show = false

func _process(delta):
    if fade_timeout > 0:
        fade_timeout -= delta
        fade_timeout = max(fade_timeout, 0)
        if show:
            $sprite/front.modulate.a = fade_timeout/FADE_TIME
        else:
            $sprite/front.modulate.a = 1 - fade_timeout/FADE_TIME

