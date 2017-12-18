extends Node2D

const BULLET = null
const ENTITY = null
const SPEED = 500
const TIMEOUT = 0.2
const OFFSET = Vector2(40, -10)
const GUN_CLASS = "pistol"
const VIEWPORT_SHUTTER = 0
const DROP_VELOCITY = Vector2(400,-400)
const DROP_ANGULAR = 10

var wait_ready = 0
var fired = false
var camera

func _ready():
    set_position(OFFSET)

func get_gun_class():
    return GUN_CLASS

func set_camera(camera):
    self.camera = camera

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
    f.set_scale(Vector2(0.1, 0.1))

    var spawn_point = $to.global_position
    var bullet_velocity = (spawn_point - $from.global_position).normalized()
    f.rotate(Vector2(1, 0).angle_to(bullet_velocity))
    f.set_axis_velocity(bullet_velocity*SPEED)
    f.set_global_position(spawn_point)
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