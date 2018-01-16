extends KinematicBody2D

const constants = preload("res://scripts/constants.gd")

var dead
var health = 100
var gui
var gun
var movement

var shuffle = 0
var shuffle_time = 0
var shuffle_timeout = 0
var camera_offset = Vector2()

func _ready():
    set_collision_layer(constants.PLAYER_LAYER)
    set_collision_mask(constants.PLAYER_MASK)

    movement = load("res://scripts/player/movement.gd").new(self, $animation_tree_player)
    gui = get_tree().get_root().get_node("world/gui")
    _update_health()
    movement.look_default()
    camera_offset = $camera.get_offset()

func set_gun(gun_class):
    if gun:
        return false
    gun = load(gun_class).instance()

    get_node("base/body/sholder_r/forearm_r/gun_position").add_child(gun)
    movement.set_gun()
    return true

func drop_gun():
    if gun:
        gun.drop()
        gun = null
    movement.drop_gun()

func gun_reload():
    movement.gun_reload()

func gun_recoil(recoil_vector):
    movement.gun_recoil(recoil_vector)

func hit(damage):
    movement.input.vibrate(0.1)
    health -= damage
    _update_health()

func _update_health():
    gui.set_health(health)

func _fire(delta):
    if not gun:
        return
    gun.fire(delta, movement.velocity)

func _footstep_sound():
    $audio_footstep.play()

func _input(event):
    if event.is_action_pressed("ui_jump"):
        movement.jump()

    if event.is_action_released("ui_drop"):
        drop_gun()

    if event is InputEventMouseButton:
        if event.button_index == BUTTON_RIGHT and event.pressed:
            movement.jump()

func shuffle_camera(force, fade_out_time=0.1):
    shuffle = force*[-1,1][randi()%2]
    $camera.set_offset(Vector2(camera_offset.x, camera_offset.y + shuffle))
    shuffle_timeout = fade_out_time

func _process(delta):
    if shuffle_timeout > 0:
        shuffle_timeout -= delta
        if shuffle_timeout <= 0:
            $camera.set_offset(camera_offset)
        else:
            shuffle_time += delta
            if shuffle_time > 0.1:
                shuffle *= -0.8
                $camera.set_offset(Vector2(camera_offset.x, camera_offset.y + shuffle))
                shuffle_time = 0

func _physics_process(delta):
    if Input.is_action_pressed("ui_fire"):
        _fire(delta)

    if Input.is_mouse_button_pressed(BUTTON_LEFT):
        _fire(delta)

    movement.process(delta)

    if movement.is_back():
        $camera.drag_margin_left = 0.3
        $camera.drag_margin_right = 0.1
    else:
        $camera.drag_margin_left = 0.1
        $camera.drag_margin_right = 0.3