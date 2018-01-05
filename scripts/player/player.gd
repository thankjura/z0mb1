extends KinematicBody2D

const constants = preload("res://scripts/constants.gd")

var dead
var health = 100
var gui
var gun
var movement

func _ready():
    set_collision_layer(constants.PLAYER_LAYER)
    set_collision_mask(constants.PLAYER_MASK)

    movement = load("res://scripts/player/movement.gd").new(self, $anim_tree)
    gui = get_tree().get_root().get_node("world/gui")
    _update_health()
    movement.look_default()

func set_gun(gun_class):
    if gun:
        return false
    gun = gun_class.instance()
    gun.set_name("gun")
    movement.set_gun()
    get_node("body/arm_r/hand_r/gun_position").add_child(gun)
    gun.set_camera($camera)
    return true

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

func _drop_gun():
    if gun:
        gun.drop()
        gun = null

func _fire(delta):
    if not gun:
        return
    gun.fire(delta)

func _input(event):
    if event.is_action_pressed("ui_jump"):
        movement.jump()

    if event.is_action_released("ui_drop"):
        _drop_gun()

func _physics_process(delta):
    if Input.is_action_pressed("ui_fire"):
        _fire(delta)
    movement.process(delta)