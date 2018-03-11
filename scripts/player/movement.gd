const MAX_JUMP_COUNT = 2
const MAX_FALL_SPEED = 800
const GRAVITY = 2000
const MAX_JUMP_SPEED = 800
const INIT_JUMP_FORCE = 800
const INIT_MAX_SPEED = 400
const INIT_MAX_CLIMB_SPEED = 200
const INIT_ACCELERATION = 10

var ACCELERATION = INIT_ACCELERATION
const AIR_ACCELERATION = 10
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_FRICTION = 10
const MAX_BOUNCES = 4
const FLOOR_MAX_ANGLE = 0.8
const DEFAULT_VECTOR = Vector2(0, -1)

var MAX_SPEED = INIT_MAX_SPEED
var MAX_CLIMB_SPEED = INIT_MAX_CLIMB_SPEED
var JUMP_FORCE = INIT_JUMP_FORCE

const RECOIL_DEACCELERATION = 20

var input
var player
var anim

var jump_count = 0
var velocity = Vector2()

var recoil = Vector2(0, 0)

var air_state = false
var climb_state = false
var climb_ladder = null
var climb_ladder_direction = 0

func _init(var player, var anim):
    self.player = player
    self.input = load("res://scripts/input.gd").new()
    self.anim = anim

func set_ladder(ladder):
    if ladder:
        climb_state = true
        climb_ladder_direction = 1 if player.global_position.x < ladder.global_position.x else -1
    else:
        climb_state = false
    climb_ladder = ladder

func _recalc_mass():
    if player.gun:
        MAX_SPEED = INIT_MAX_SPEED - INIT_MAX_SPEED * player.gun.get("player/heavines")
        MAX_CLIMB_SPEED = INIT_MAX_CLIMB_SPEED - INIT_MAX_CLIMB_SPEED * player.gun.get("player/heavines")
        JUMP_FORCE = INIT_JUMP_FORCE - INIT_JUMP_FORCE * pow(player.gun.get("player/heavines"), 2)
        ACCELERATION = INIT_ACCELERATION + ACCELERATION * player.gun.get("player/heavines")
    else:
        MAX_SPEED = INIT_MAX_SPEED
        MAX_CLIMB_SPEED = INIT_MAX_CLIMB_SPEED
        JUMP_FORCE = INIT_JUMP_FORCE
        ACCELERATION = INIT_ACCELERATION

func _ground_state(delta, m = Vector2(), floor_ratio = null):
    air_state = false
    jump_count = 0    
    velocity.x = lerp(velocity.x, m.x * MAX_SPEED, ACCELERATION*delta)
    var v = 0
    if abs(velocity.x) > 0.1:
        v = velocity.length() * sign(velocity.x)
    
    var direction = -1 if is_back() else 1
    if floor_ratio != null:
        anim.set_floor_ratio(floor_ratio*2, direction)
    anim.walk(v, delta, direction, MAX_SPEED)

func _climb_state(delta, m = Vector2()):
    air_state = false
    var movement = 0
    if m.y > 0: # press down
        movement = -max(m.x*climb_ladder_direction, m.y)
    elif m.y < 0: # press up
        movement = -min(m.x*climb_ladder_direction, m.y)
    else:
        movement = m.x * climb_ladder_direction

    if movement < 0 and player.is_on_floor():
        climb_state = false
        _ground_state(delta, Vector2(-movement*climb_ladder_direction, 0))
        return

    var distance = player.get_node("climb_center").global_position.y - climb_ladder.global_position.y
    if distance < 0 and abs(distance) > anim.CLIMB_LADDER_BOT_DISTANCE:
        climb_state = false
        jump()
        return

    if climb_ladder_direction > 0:
        _set_player_direction(1)

    elif climb_ladder_direction < 0:
        _set_player_direction(-1)

    velocity.y = lerp(velocity.y, -movement * MAX_CLIMB_SPEED, ACCELERATION*delta)
    velocity.x = 0
    anim.climb(velocity, delta, MAX_CLIMB_SPEED, distance)

func _air_state(delta, m = Vector2()):
    var movement = m.x * MAX_SPEED
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
        _set_player_direction(1)
    elif deg > -180 and deg < 0:
        _set_player_direction(-1)

func _set_player_direction(d):
    player.get_node("base").set_scale(Vector2(d,1))
    anim.set_player_direction(d)

func look_default(delta):
    if player.gun:
        anim.aim(90, delta)

func jump():
    if climb_state:
        velocity.y -= JUMP_FORCE * 0.7
        velocity.x += JUMP_FORCE * 0.7 * -climb_ladder_direction
        climb_state = false
    elif jump_count < MAX_JUMP_COUNT:
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

    if -new_recoil.y < GRAVITY:
        new_recoil.y = 0
    recoil += new_recoil

func is_back():
    return player.get_node("base").scale.x != 1

func get_ratio_x():
    return abs(velocity.x)/MAX_SPEED

func get_ratio_y():
    return abs(velocity.y)/MAX_CLIMB_SPEED

func process(delta):
    var ratio = null
    if not climb_state:        
        if player.get_slide_count() > 0:
            var c = player.get_slide_collision(0)
            var a = FLOOR_NORMAL.angle_to(c.normal)
            if abs(a) < FLOOR_MAX_ANGLE:                
                ratio = a/anim.ANIM_CLIMB_ANGLE
        if ratio != null and ratio < 0 and velocity.x > 0.001:
            velocity.y += (GRAVITY + (GRAVITY * ratio)) * delta
        else:
            velocity.y += GRAVITY * delta
    var move_vector = input.get_move_vector()
    var direction = input.get_direction(player)

    if climb_state:
        _climb_state(delta, move_vector)
    else:
        if player.is_on_floor():
            _ground_state(delta, move_vector, ratio)
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

        velocity.y = clamp(velocity.y, -MAX_JUMP_SPEED, MAX_FALL_SPEED)        

    velocity = player.move_and_slide(velocity + recoil, FLOOR_NORMAL, true, SLOPE_FRICTION, MAX_BOUNCES, FLOOR_MAX_ANGLE)
    velocity -= recoil
    var new_recoil = recoil.linear_interpolate(Vector2(), RECOIL_DEACCELERATION*delta)
    if sign(recoil.x) != sign(new_recoil.x):
        new_recoil.x = 0
    if sign(recoil.y) != sign(new_recoil.y):
        new_recoil.y = 0
    recoil = new_recoil