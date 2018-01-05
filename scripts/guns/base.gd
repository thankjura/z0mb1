extends Node2D

const BULLET = null
const ENTITY = null
const SPEED = 500
const TIMEOUT = 0.2
const OFFSET = Vector2(40, -10)
const AIM_NAME = "aim_pistol"
const VIEWPORT_SHUTTER = 0
const DROP_VELOCITY = Vector2(400,-400)
const DROP_ANGULAR = 10
const RECOIL = Vector2(0, 0)
const SPREADING = 0.0

var wait_ready = 0
var fired = false
var camera

func _ready():
    set_position(OFFSET)

func set_camera(camera):
    self.camera = camera

func _get_bullet_velocity(from_position, to_position):
    var out = (to_position - from_position).normalized()
    if SPREADING:
        out = out.rotated(SPREADING - randf()*SPREADING*2)

    return out

func _get_bullet_position(gun_angle):
    return $to.global_position

func fire(delta):
    if wait_ready > 0:
        return
    wait_ready = TIMEOUT

    if not fired:
        fired = true
        _fire_start(delta)
    _shutter_camera(delta)
    _muzzle_flash(delta)
    _play_sound(delta)
    var f = BULLET.instance()
    var spawn_point = $to.global_position
    var bullet_velocity = _get_bullet_velocity($from.global_position, spawn_point)
    var gun_angle = Vector2(1, 0).angle_to(bullet_velocity)
    _recoil(RECOIL.rotated(bullet_velocity.angle()))
    f.rotate(gun_angle)
    f.set_axis_velocity(bullet_velocity*SPEED)
    f.set_global_position(_get_bullet_position(gun_angle))
    var world = get_tree().get_root().get_node("world")
    world.add_child(f)

func _fire_start(delta):
    pass

func _fire_stop(delta):
    if camera:
        camera.set_offset(Vector2(0,0))

func _muzzle_flash(delta):
    if has_node("anim") and $anim.has_animation("fire"):
        $anim.play("fire", -1, 2)

func _recoil(recoil_vector):
    get_parent().get_owner().gun_recoil(recoil_vector)

func _shutter_camera(delta):
    if not camera or not VIEWPORT_SHUTTER:
        return
    camera.set_offset(Vector2(randf(), randf()) * VIEWPORT_SHUTTER)

func _play_sound(delta):
    if has_node("audio"):
        $audio.play()

func drop():
    if ENTITY:
        var entity = ENTITY.instance()
        entity.set_global_position(global_position)
        if $from.global_position.x <= $to.global_position.x:
            entity.set_angular_velocity(DROP_ANGULAR)
            entity.set_linear_velocity(Vector2(-DROP_VELOCITY.x,DROP_VELOCITY.y))
        else:
            entity.set_angular_velocity(-DROP_ANGULAR)
            entity.set_linear_velocity(DROP_VELOCITY)
        var world = get_tree().get_root().get_node("world")
        world.add_child(entity)
    queue_free()

func _physics_process(delta):
    if wait_ready > 0:
        wait_ready -= delta
    elif fired:
        fired = false
        _fire_stop(delta)