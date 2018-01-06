extends "res://scripts/enemy/base_enemy.gd"

const DIE_ANIMATIONS = ["die1", "die2"]
var die_explode_body = false

func _ready():
    get_node("body/attack_area").set_collision_layer(constants.ENEMY_ATTACK_LAYER)
    get_node("body/attack_area").set_collision_mask(constants.ENEMY_ATTACK_MASK)
    $anim.set_speed_scale(MOVEMENT_ANIMATION_SPEED)
    $anim.connect("animation_finished", self, "_end_animation")

func _get_die_animation():
    return DIE_ANIMATIONS[randi() % DIE_ANIMATIONS.size()]

func _end_animation(anim_name):
    if anim_name == "attack" and attacking == true:
        attacking = false
        if get_node("body/attack_area").overlaps_body(player):
            player.hit(ATTACK_DAMAGE)
    if anim_name == "climb_up":
        _activate()

func _activate():
    alive = true
    set_light_mask(1)
    get_node("body/attack_area").set_monitoring(true)
    if source_position:
        source_position.set_meta("free", true)

func _attack():
    if not attacking and player:
        attacking = true
        $anim.seek(0)
        $anim.play("attack")

func hit(body):
    .hit(body)
    if has_node("blood"):
        $blood.start(body)

func die():
    .die()
    if has_node("anim"):
        $anim.play(_get_die_animation(), 0.2)
    if is_in_group("enemy"):
        remove_from_group("enemy")
    if die_explode_body:
        queue_free()
    else:
        alive = false
        if has_node("body/attack_area"):
            get_node("body/attack_area").queue_free()

func init_from_hole(pos):
    source_position = pos
    $anim.play("climb_up")

func _integrate_forces(s):
    if not alive:
        return
    if not attacking:
        var v = s.get_linear_velocity()

        if player.global_position.distance_squared_to(global_position) < ATTACK_DISTANSE_SQUARED:
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
                $anim.play("walk", 1, MOVEMENT_ANIMATION_SPEED)

        v.x = direction * MOVEMENT_SPEED
        s.set_linear_velocity(v)