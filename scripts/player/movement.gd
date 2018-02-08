const MAX_JUMP_COUNT = 2
const MAX_FALL_SPEED = 800
const MAX_JUMP_SPEED = 800
const INIT_GRAVITY = Vector2(0, 2000)
const INIT_MAX_SPEED = 400
const INIT_MAX_CLIMB_SPEED = 400

const JUMP_FORCE = 800
const ACCELERATION = 20
const AIR_ACCELERATION = 10
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_FRICTION = 5
const MAX_BOUNCES = 4
const FLOOR_MAX_ANGLE = 0.8
const DEFAULT_VECTOR = Vector2(0, -1)

var MOVEMENT_MODE = 1
var MAX_SPEED = INIT_MAX_SPEED
var MAX_CLIMB_SPEED = INIT_MAX_CLIMB_SPEED
var GRAVITY = INIT_GRAVITY
const RECOIL_DEACCELERATION = 20

var input
var player
var anim

var jump_count = 0
var velocity = Vector2()

var recoil = Vector2(0, 0)

var air_state = false
var climb_state = false

func _init(var player, var anim):
    self.player = player
    self.input = load("res://scripts/input.gd").new()
    self.anim = anim

func _recalc_mass():
    if player.gun:
        MAX_SPEED = INIT_MAX_SPEED - INIT_MAX_SPEED * player.gun.HEAVINES
        MAX_CLIMB_SPEED = INIT_MAX_CLIMB_SPEED - INIT_MAX_CLIMB_SPEED * player.gun.HEAVINES
        GRAVITY = INIT_GRAVITY + INIT_GRAVITY * player.gun.HEAVINES
    else:
        MAX_SPEED = INIT_MAX_SPEED
        MAX_CLIMB_SPEED = INIT_MAX_CLIMB_SPEED
        GRAVITY = INIT_GRAVITY

func _ground_state(delta, m = Vector2(), direction = 1):
    air_state = false
    var movement = 0
    if m.x < 0:
        movement = -1
    elif m.x > 0:
        movement = 1
    velocity.x = lerp(velocity.x, movement * MAX_SPEED, ACCELERATION*delta)
    anim.walk(velocity.x, delta, direction, MAX_SPEED)

func _climb_state(delta, m = Vector2()):
    air_state = false
    var movement = 0
    if m.y < 0:
        movement = -1
    elif m.y > 0:
        movement = 1
    velocity.y = lerp(velocity.x, movement * MAX_CLIMB_SPEED, ACCELERATION*delta)
    # TODO: velocity.x to velocity.y
    if velocity.x > 0:
        player.get_node("base").set_scale(Vector2(1,1))
    elif velocity.x < 0:
        player.get_node("base").set_scale(Vector2(-1,1))
    velocity.x = 0
    anim.climb(velocity, delta, movement, MAX_CLIMB_SPEED)

func _air_state(delta, m = Vector2()):
    var movement = 0
    if m.x < 0:
        movement = -1
    elif m.x > 0:
        movement = 1
    movement *= MAX_SPEED
    velocity.x = lerp(velocity.x + recoil.x, movement, AIR_ACCELERATION*delta)

    if velocity.y and air_state:
        anim.jump(velocity)
    else:
        air_state = true

func _look(rad, delta):
    var deg = rad2deg(rad)
    if player.gun:
        anim.aim(deg, delta)

    if deg > 0 and deg < 180:
        player.get_node("base").set_scale(Vector2(1,1))
    elif deg > -180 and deg < 0:
        player.get_node("base").set_scale(Vector2(-1, 1))

func look_default(delta):
    if player.gun:
        anim.aim(90, delta)

func jump():
    if jump_count < MAX_JUMP_COUNT:
        jump_count += 1
        velocity.y = -JUMP_FORCE

func set_gun():
    _recalc_mass()
    anim.set_gun()

func drop_gun():
    _recalc_mass()
    anim.drop_gun()

func gun_recoil(recoil_vector):
    var new_recoil = recoil_vector

    if -new_recoil.y < GRAVITY.y:
        new_recoil.y = 0
    recoil += new_recoil

func is_back():
    return player.get_node("base").scale.x != 1

func get_ratio_x():
    return abs(velocity.x)/MAX_SPEED

func process(delta):
    if not climb_state:
        velocity += GRAVITY * delta

    var move_vector = input.get_move_vector()
    var direction = move_vector
    if MOVEMENT_MODE == 1:
        if player.gun:
            direction = (player.get_global_mouse_position() - player.gun.get_node("pos").global_position).normalized()
            var dist = abs((player.global_position.x - player.get_global_mouse_position().x))
            if player.get_global_mouse_position().y > player.gun.get_node("pos").global_position.y:
                if dist < player.gun.ANIM_DEAD_ZONE_BOTTOM:
                    direction.x = 0
            else:
                if dist < player.gun.ANIM_DEAD_ZONE_TOP:
                    direction.x = 0
        else:
            direction = input.get_direction(player)

    if climb_state:
        _climb_state(delta, move_vector)
    else:
        if player.is_on_floor():
            jump_count = 0
            var d = 0
            if direction.x > 0:
                d = 1
            elif direction.x < 0:
                d = -1
            _ground_state(delta, move_vector, d)
            if abs(velocity.x) > MAX_SPEED:
                velocity.x = sign(velocity.x) * MAX_SPEED
        else:
            _air_state(delta, move_vector)
            if abs(velocity.x) > MAX_SPEED:
                velocity.x = sign(velocity.x) * MAX_SPEED

        if direction:
            _look(DEFAULT_VECTOR.angle_to(direction), delta)
        else:
            look_default(delta)

        if -velocity.y > MAX_JUMP_SPEED:
            velocity.y = -MAX_JUMP_SPEED

        if velocity.y > MAX_FALL_SPEED:
            velocity.y = MAX_FALL_SPEED

    velocity = player.move_and_slide(velocity + recoil, FLOOR_NORMAL, SLOPE_FRICTION, MAX_BOUNCES, FLOOR_MAX_ANGLE)
    velocity -= recoil
    var new_recoil = recoil.linear_interpolate(Vector2(), RECOIL_DEACCELERATION*delta)
    if sign(recoil.x) != sign(new_recoil.x):
        new_recoil.x = 0
    if sign(recoil.y) != sign(new_recoil.y):
        new_recoil.y = 0
    recoil = new_recoil