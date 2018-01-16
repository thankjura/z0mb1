extends "res://scripts/guns/bullets/base.gd"

const DAMAGE = 1000
const HEALTH = 10
const MAX_ROTATE = 0.03 # rad
const ROTATE_TIME = 0.2

var ROTATION_SPEED = MAX_ROTATE / ROTATE_TIME

var rotation_time = 0
var direction = 1
var v

func _ready():
    $boom.connect("animation_finished", self, "_animation_finish")
    $audio_boom.connect("finished", self, "_sound_finish")
    $audio_fire.play()

func _animation_finish():
    $boom.set_visible(false)

func _sound_finish():
    queue_free()

func _deactivate():
    active = false
    $audio_fire.stop()
    $sprite.set_visible(false)
    set_applied_force(Vector2())
    set_mode(MODE_STATIC)
    if is_connected("body_entered", self, "_collision"):
        disconnect("body_entered", self, "_collision")
    $particles.set_emitting(false)
    $boom.set_visible(true)
    $boom.play("default")
    $audio_boom.play()
    timer = 4
    get_node("/root/world/player").shuffle_camera(20, 1)

func _process(delta):
    timer -= delta
    if timer <= 0:
        _deactivate()