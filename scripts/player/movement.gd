const MAX_JUMP_COUNT = 2
const MAX_FALL_SPEED = 800
const GRAVITY = Vector2(0, 2000)

const JUMP_FORCE = 800
const WALK_ACCELERATION = 0.6
const WALK_MAX_SPEED = 300
const WALK_AIR_MAX_SPEED = 250
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_FRICTION = 20
const DEFAULT_VECTOR = Vector2(0, -1)

const GROUND_BLEND_NODE = "ground_blend"
const GROUND_SCALE_NODE = "ground_scale"
const STATE_NODE = "ground_air_transition"
const AIM_BLEND_NODE = "aim_blend"
const AIM_SWITCH_NODE = "aim_transition"
const SHOTGUN_RELOAD_NODE = "shotgun_reload"

const AIM_SHOTGUN_NAME = "aim_shotgun"

enum STATE {
    ground,
    jump_up,
    jump_down
}

enum AIM {
    aim_pistol,
    aim_minigun,
    aim_shotgun
}

var input
var player
var anim

var jump_count = 0
var velocity = Vector2()

var direction = 0

var body_scale

var aim_animation_name = "aim_pistol"
var reload_timeout = 0

func _init(var player, var anim):
    self.player = player
    self.body_scale = player.get_node("body").scale
    self.anim = anim
    self.anim.set_active(true)
    self.input = load("res://scripts/input.gd").new()

func _ground_state(delta, m = Vector2()):
    var movement = 0
    if m:
        _look(DEFAULT_VECTOR.angle_to(m))
    else:
        look_default()

    if m.x < 0:
        movement = -1
    elif m.x > 0:
        movement = 1
    movement *= WALK_MAX_SPEED
    velocity.x = lerp(velocity.x, movement, WALK_ACCELERATION)
    anim.blend2_node_set_amount(GROUND_BLEND_NODE, abs(velocity.x) / WALK_MAX_SPEED)    
    anim.timescale_node_set_scale(GROUND_SCALE_NODE, abs(velocity.x)*delta)
    anim.transition_node_set_current(STATE_NODE, STATE.ground)

func _air_state(delta, m = Vector2()):
    var movement = 0
    if m:
        _look(DEFAULT_VECTOR.angle_to(m))
    else:
        look_default()
    if m.x < 0:
        movement = -1
    elif m.x > 0:
        movement = 1
    movement *= WALK_AIR_MAX_SPEED
    velocity.x = lerp(velocity.x, movement, WALK_ACCELERATION)

    if velocity.y > 0:
        anim.transition_node_set_current(STATE_NODE, STATE.jump_down)
    elif velocity.y < 0:
        anim.transition_node_set_current(STATE_NODE, STATE.jump_up)

func _look(rad):
    var deg = rad2deg(rad)
    if player.gun:
        anim.timeseek_node_seek("gun_angle", abs(deg))

    if deg > 0 and deg < 180:
        player.get_node("body").set_scale(body_scale)
    elif deg > -180 and deg < 0:
        player.get_node("body").set_scale(Vector2(-body_scale.x, body_scale.y))

func look_default():
    if player.gun:
        anim.timeseek_node_seek("gun_angle", 90)

func jump():
    if jump_count < MAX_JUMP_COUNT:
        jump_count += 1
        velocity.y = -JUMP_FORCE

func set_gun():
    anim.transition_node_set_current(AIM_SWITCH_NODE, AIM[player.gun.AIM_NAME])

func gun_reload():
    if player.gun and player.gun.AIM_NAME == AIM_SHOTGUN_NAME:
        anim.oneshot_node_start(SHOTGUN_RELOAD_NODE)        
        reload_timeout = 0.3
        
func _stop_gun_reload():
    if player.gun and player.gun.AIM_NAME == AIM_SHOTGUN_NAME:
        anim.oneshot_node_stop(SHOTGUN_RELOAD_NODE)

func process(delta):
    if reload_timeout > 0:
        reload_timeout -= delta
        if reload_timeout <= 0:
            _stop_gun_reload()
    
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
        anim.blend2_node_set_amount(AIM_BLEND_NODE, 0)
    else:
        anim.blend2_node_set_amount(AIM_BLEND_NODE, 1)