extends RigidBody2D

const constants = preload("res://scripts/constants.gd")

const LIFE_TIME = 4
const DAMAGE = 30
const HEALTH = 100
const GRAVITY = 0

var health = HEALTH
var active = true
var decal = false
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

    if has_node("decal"):
        $decal.set_visible(true)
    else:
        queue_free()

func damage(d):
    health -= d
    if health <= 0:
        _deactivate()