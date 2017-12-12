const MAX_JUMP_COUNT = 2
const MAX_FALL_SPEED = 800
const GRAVITY = Vector2(0, 2000)

const JUMP_FORCE = 800
const WALK_ACCELERATION = 0.6
const WALK_MAX_SPEED = 300
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_FRICTION = 20

var player
var aim
var anim

var jump_count = 0
var velocity = Vector2()

var direction = 0

var anim = ""
var new_anim = ""

func _init(var player, var aim, var anim):
    self.player = player
    self.aim = aim
    self.anim = anim
    self.input = load("res://scripts/input.gd").new()

func _ground_state(delta, m = Vector2()):
    var movement = 0


    if right:
        if down:
            aim.look(45, gun)
        elif up:
            aim.look(315, gun)
        else:
            aim.look(0, gun)
    elif left:
        if down:
            aim.look(135, gun)
        elif up:
            aim.look(225, gun)
        else:
            aim.look(180, gun)
    else:
        if down:
            aim.look(90, gun)
        elif up:
            aim.look(270, gun)
        else:
            aim.look_default(gun)

    if left:
        movement = -1
    elif right:
        movement = 1

    movement *= WALK_MAX_SPEED

    velocity.x = lerp(velocity.x, movement, WALK_ACCELERATION)

func _air_state(delta):
    pass

func _look(deg, gun):
    if gun:
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
        player.get_node("body").set_scale(player.body_scale)
    elif deg < 270 and deg > 90:
        player.get_node("body").set_scale(Vector2(-player.body_scale.x, player.body_scale.y))

func _look_default(gun):
    if gun:
        aim.set_active(true)
        aim.seek(90, true)
    else:
        aim.set_active(false)

func _movement_process(delta):
    velocity += GRAVITY * delta
    if velocity.y > MAX_FALL_SPEED:
        velocity.y = MAX_FALL_SPEED




    if is_on_floor():
        _ground_state(delta)
    else:
        _air_state(delta)

    velocity = move_and_slide(velocity, FLOOR_NORMAL, SLOPE_FRICTION)