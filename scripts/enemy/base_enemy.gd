extends RigidBody2D

const constants = preload("res://scripts/constants.gd")
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
var alive = false
var die_explode_body = false
var source_position

func _ready():
    set_collision_layer(constants.ENEMY_LAYER)
    set_collision_mask(constants.ENEMY_MASK)
    get_node("body/attack_area").set_collision_layer(constants.ENEMY_ATTACK_LAYER)
    get_node("body/attack_area").set_collision_mask(constants.ENEMY_ATTACK_MASK)
    player = get_parent().get_node("player")
    body_scale = $body.scale

    if $anim:
        $anim.set_speed_scale(WALK_ANIMATION_SPEED)
        $anim.connect("animation_finished", self, "_end_animation")

func _activate():
    alive = true
    #set_light_mask(1)
    get_node("body/attack_area").set_monitoring(true)
    if source_position:
        source_position.set_meta("free", true)

func _attack():
    if not attacking and player:
        attacking = true
        $anim.seek(0)
        $anim.play("attack")

func _end_animation(anim_name):
    if anim_name == "attack" and attacking == true:
        attacking = false
        if get_node("body/attack_area").overlaps_body(player):
            player.hit(ATTACK_DAMAGE)
    if anim_name == "climb_up":
        _activate()

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
            if not $anim.is_playing() or $anim.get_current_animation() != "walk":
                $anim.play("walk", 1, WALK_ANIMATION_SPEED)

        v.x = direction * WALK_SPEED
        s.set_linear_velocity(v)

func _get_die_animation():
    return DIE_ANIMATIONS[randi() % DIE_ANIMATIONS.size()]

func _die():
    set_contact_monitor(false)
    set_collision_layer(0)
    set_collision_mask(constants.GROUND_LAYER)
    if is_in_group("enemy"):
        remove_from_group("enemy")
    if die_explode_body:
        queue_free()
    else:
        alive = false
        get_node("body/attack_area").queue_free()
        if $anim:
            $anim.play(_get_die_animation(), 0.2)

func hit(body):
    health -= body.DAMAGE
    body.damage(STRENGTH)
    if $blood:
        $blood.start(body)
    if health <= 0:
        _die()

func init_from_hole(pos):
    source_position = pos
    $anim.play("climb_up")