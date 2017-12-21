extends RigidBody2D

const constants = preload("res://scripts/constants.gd")

const LIFE_TIME = 10
const DAMAGE = 30
const HEALTH = 100
const GRAVITY = 0

var health = HEALTH
var active = true
var timer = 0

func _ready():
    set_collision_layer(constants.BULLET_LAYER)
    set_collision_mask(constants.BULLET_MASK)
    set_contact_monitor(true)
    set_max_contacts_reported(3)
    set_gravity_scale(GRAVITY)

    connect("body_entered", self, "_collision")
    if has_node("particles"):
        var s = get_viewport_rect().size
        $particles.set_visibility_rect(Rect2(-s, s*2))

    timer = LIFE_TIME


func _process(delta):
    timer -= delta
    if timer <= 0:
        if active and has_node("particles"):
            _deactivate()
            timer = $particles.lifetime/$particles.speed_scale
        else:
            queue_free()

func _collision(body):
    if body.has_method("hit"):
        body.hit(self)
    else:
        _deactivate()

func _deactivate():
    active = false
    disconnect("body_entered", self, "_collision")
    if has_node("light"):
        $light.queue_free()

    if has_node("particles"):
        $particles.set_emitting(false)
        $sprite.set_visible(false)
    else:
        queue_free()

func damage(d):
    health -= d
    if health <= 0:
        _deactivate()