const MAX_JUMP_COUNT = 2
const MAX_FALL_SPEED = 800
const GRAVITY = Vector2(0, 2000)

const JUMP_FORCE = 800
const WALK_ACCELERATION = 0.6
const WALK_MAX_SPEED = 300
const WALK_AIR_MAX_SPEED = 250
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_FRICTION = 20

const DEFAULT_VECTOR = Vector2(1, 0)

var input
var player
var aim
var anim

var jump_count = 0
var velocity = Vector2()

var direction = 0

var current_anim = ""
var new_anim = ""
var body_scale

func _init(var player, var aim, var anim):
    self.player = player
    self.body_scale = player.get_node("body").scale
    self.aim = aim
    self.anim = anim
    self.input = load("res://scripts/input.gd").new()

func _ground_state(delta, m = Vector2()):
    var movement = 0
    var angle = DEFAULT_VECTOR.angle_to(m)
    if m:
        _look(angle)
    else:
        look_default()

    if m.x < 0:
        movement = -1
    elif m.x > 0:
        movement = 1
    movement *= WALK_MAX_SPEED
    velocity.x = lerp(velocity.x, movement, WALK_ACCELERATION)

func _air_state(delta, m = Vector2()):
    var movement = 0
    var angle = DEFAULT_VECTOR.angle_to(m)

    if m:
        _look(angle)
    else:
        look_default()

    if m.x < 0:
        movement = -1
    elif m.x > 0:
        movement = 1
    movement *= WALK_AIR_MAX_SPEED
    velocity.x = lerp(velocity.x, movement, WALK_ACCELERATION)

func _look(rad):
    var deg = rad2deg(rad)
    if deg < 0:
        deg = 360 + deg
    if player.gun:
        aim.set_active(true)
        aim.set_current_animation("aim")
        if deg >= 270:
            aim.seek(450 - deg, true)
        elif deg <=90:
            aim.seek(abs(deg - 90), true)
        else:
            aim.seek(abs(deg - 90), true)
    else:
        aim.set_active(true)

    if deg > 270 or deg < 90:
        player.get_node("body").set_scale(body_scale)
    elif deg < 270 and deg > 90:
        player.get_node("body").set_scale(Vector2(-body_scale.x, body_scale.y))

func look_default():
    if player.gun:
        aim.set_active(true)
        aim.seek(90, true)
    else:
        aim.set_active(false)

func jump():
    if jump_count < MAX_JUMP_COUNT:
        jump_count += 1
        velocity.y = -JUMP_FORCE

func move(delta):
    velocity += GRAVITY * delta
    if velocity.y > MAX_FALL_SPEED:
        velocity.y = MAX_FALL_SPEED

    var move_vector = input.get_move_vector()

    if player.is_on_floor():
        jump_count = 0
        _ground_state(delta, move_vector)
    else:
        _air_state(delta, move_vector)

    velocity = player.move_and_slide(velocity, FLOOR_NORMAL, SLOPE_FRICTION)

    if not player.gun:
        aim.stop()

    if move_vector.x:
        if player.gun:
            new_anim = "walk_aim"
        else:
            new_anim = "walk"

        anim.set_speed_scale(abs(velocity.x*delta))

    else:
        if player.gun:
            new_anim = "idle_aim"
        else:
            new_anim = "idle"

    if current_anim != new_anim:
        current_anim = new_anim
        anim.play(current_anim)