extends RigidBody2D

const constants = preload("res://scripts/constants.gd")

const LIFE_TIME = 10
const DAMAGE = 30

onready var world = get_tree().get_root().get_node("world")

var active = true
var decal = false
var timer = 0

func _ready():
    set_collision_layer(constants.ENEMY_BULLET_LAYER)
    set_collision_mask(constants.ENEMY_BULLET_MASK)
    set_contact_monitor(true)
    set_max_contacts_reported(1)

    connect("body_entered", self, "_collision")
    if has_node("particles"):
        var s = get_viewport_rect().size
        $particles.set_visibility_rect(Rect2(-s, s*2))

    timer = LIFE_TIME

func _process(delta):
    timer -= delta
    if timer <= 0:
        queue_free()

func _collision(body):
    if body.has_method("hit"):
        body.hit(DAMAGE)
        _deactivate()
    else:
        decal = body.is_in_group("decals")
        _deactivate()

func _deactivate():
    active = false
    $sprite.set_visible(false)
    set_applied_force(Vector2())
    set_mode(MODE_STATIC)
    disconnect("body_entered", self, "_collision")
    if has_node("light"):
        $light.queue_free()

    if has_node("particles"):
        $particles.set_emitting(false)

    if decal and has_node("decal"):
        $decal.set_visible(true)
    else:
        queue_free()
