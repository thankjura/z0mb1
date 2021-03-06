extends "res://scripts/guns/bullets/base.gd"

const DAMAGE = 1000
const HEALTH = 10
const LIFE_TIME = 60
const LOCAL_DAMP_TIME = 0.8

const SHOCK_WAVE_FORCE = 40000
var SHOCK_WAVE_DISTANCE_SQUARED = 1

var local_dump_timeout = 0
var local_dump_vector = Vector2()
var local_dump_length = 0

func _ready():
    $boom.connect("animation_finished", self, "_animation_finish")
    $audio_fire.play()
    $dead_zone.set_collision_layer(constants.GRENADE_LAYER)
    $dead_zone.set_collision_mask(constants.GRENADE_MASK)
    SHOCK_WAVE_DISTANCE_SQUARED = pow($dead_zone/collision.shape.radius, 2)
    local_dump_timeout = LOCAL_DAMP_TIME

func _animation_finish():
    $boom.set_visible(false)

func _collision(body):
    decal = body.is_in_group("decals")
    _deactivate()

func _damage(body):
    var distance = $dead_zone.global_position.distance_squared_to(body.global_position)
    var vector = (body.global_position - $dead_zone.global_position).normalized()
    var percent = (1 - distance/SHOCK_WAVE_DISTANCE_SQUARED)
    if body.has_method("damage"):
        body.damage(DAMAGE*percent, vector*SHOCK_WAVE_FORCE*percent)
    elif body is RigidBody2D:
        body.apply_impulse(Vector2(), vector*SHOCK_WAVE_FORCE*percent)

func _deactivate():
    active = false
    $audio_fire.stop()
    $sprite.set_visible(false)
    $decal.set_visible(true)
    set_applied_force(Vector2())
    set_mode(MODE_STATIC)
    if is_connected("body_entered", self, "_collision"):
        disconnect("body_entered", self, "_collision")
    $particles.set_emitting(false)
    $boom.set_visible(true)
    $boom.play("default")
    $audio_boom.play()
    for body in $dead_zone.get_overlapping_bodies():
        _damage(body)
    timer = 4
    get_node("/root/world/player").shuffle_camera(30, 1)

func local_dump(v):
    local_dump_vector = v
    local_dump_length = local_dump_vector.length()

func _integrate_forces(state):
    if local_dump_timeout > 0:
        local_dump_timeout -= state.step
        var v = local_dump_vector.clamped(local_dump_length*(local_dump_timeout/LOCAL_DAMP_TIME))
        state.linear_velocity -= v
        local_dump_vector -= v