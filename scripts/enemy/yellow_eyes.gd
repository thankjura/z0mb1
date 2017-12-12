extends RigidBody2D

const COLLISION_LAYER = 4
const COLLISION_MASK = 9

const WALK_SPEED = 50
const WALK_ANIMATION_SPEED = 1.3
const STRENGTH = 150
const ATTACK_DISTANSE = 100
const ATTACK_DAMAGE = 30

const DIE_ANIMATIONS = ["die1", "die2"]

var player
var direction = 1
var body_scale
var health = 100
var attacking = false
var alive = true

var die_explode_body = false

func _ready():
    set_collision_layer(COLLISION_LAYER)
    set_collision_mask(COLLISION_MASK)
    player = get_parent().get_node("player")
    body_scale = $body.scale
    set_contact_monitor(true)
    set_max_contacts_reported(3)

    if $anim:
        $anim.set_speed_scale(WALK_ANIMATION_SPEED)
        $anim.connect("animation_finished", self, "_end_animation")

func _attack():
    if not attacking and player:
        attacking = true
        $anim.seek(0)
        $anim.play("attack")

func _end_animation(anim_name):
    if anim_name == "attack" and attacking == true:
        attacking = false
        print("stop attack")
        if $attack_area.overlaps_body(player):
            player.hit(ATTACK_DAMAGE)

func _get_direction():
    if player.global_position.x > global_position.x:
        return 1
    else:
        return -1

func _integrate_forces(s):
    if not alive:
        return
    if not attacking:
        var v = s.get_linear_velocity()

        if abs(player.global_position.x - global_position.x) < ATTACK_DISTANSE:
            direction = 0
            _attack()
            return

        direction = _get_direction()
        if direction == 1:
            $body.set_scale(Vector2(-body_scale.x, body_scale.y))
        else:
            $body.set_scale(body_scale)

        if direction:
            if $anim.current_animation != "walk" or not $anim.is_playing():
                $anim.play("walk", 1, WALK_ANIMATION_SPEED)

        v.x = direction * WALK_SPEED
        s.set_linear_velocity(v)

func _get_die_animation():
    return DIE_ANIMATIONS[randi() % DIE_ANIMATIONS.size()]

func _die():
    if die_explode_body:
        queue_free()
    else:
        alive = false
        $attack_area.queue_free()
        if $anim:
            $anim.stop()
            $anim.play(_get_die_animation())
            yield($anim, "animation_finished")
        $anim.queue_free()

func hit(body):
    health -= body.DAMAGE
    body.damage(STRENGTH)
    set_collision_layer(0)
    set_collision_mask(1)
    if health <= 0:
        _die()
