extends KinematicBody2D

const constants = preload("res://scripts/constants.gd")
const INIT_HEALTH = 100
const MOUTH_AGGRESIVE = "mouth_aggresive"

var dead
var health = INIT_HEALTH
var gui
var gun
var movement
var audio

var shuffle = 0
var shuffle_time = 0
var shuffle_timeout = 0
var camera_offset = Vector2()

onready var mouth_node = $base/pelvis/body/head/mouth

func _ready():
    set_collision_layer(constants.PLAYER_LAYER)
    set_collision_mask(constants.PLAYER_MASK)
    $base/pelvis/body/head/head_area.set_collision_layer(constants.PLAYER_LETHAL_LAYER)
    $base/pelvis/body/head/head_area.set_collision_mask(constants.PLAYER_LETHAL_MASK)
    $base/pelvis/body/body_area.set_collision_layer(constants.PLAYER_LETHAL_LAYER)
    $base/pelvis/body/body_area.set_collision_mask(constants.PLAYER_LETHAL_MASK)

    movement = load("res://scripts/player/movement.gd").new(self, $animation_tree_player)
    audio = load("res://scripts/player/audio.gd").new(self)

    $body_area.connect("area_entered", self, "_area_entered")
    $body_area.connect("area_exited", self, "_area_exited")

    gui = get_tree().get_root().get_node("world/gui")
    _update_health(INIT_HEALTH)
    camera_offset = $camera.get_offset()

func _area_entered(area):
    print(area)
    if area.is_in_group("ladder"):
        movement.set_ladder(area)

    if area.is_in_group("camera_zoom"):
        $camera.area_zoom(area)

func _area_exited(area):
    if area.is_in_group("ladder"):
        movement.set_ladder(null)

    if area.is_in_group("camera_zoom"):
        $camera.reset_zoom()

func set_gun(gun_class):
    if gun:
        return false
    gun = load(gun_class).instance()

    get_node("base/pelvis/body/sholder_r/forearm_r/gun_position").add_child(gun)
    movement.set_gun()
    return true

func drop_gun():
    if gun:
        gun.drop()
        gun = null
    movement.drop_gun()

func gun_reload():
    $animation_tree_player.gun_reload()

func gun_recoil(recoil_vector):
    movement.gun_recoil(recoil_vector)

func hit(d):
    _update_health(health - d)

func damage(d, v):
    gun_recoil(v/10)
    _update_health(health - d)

func _update_health(new_health):
    var power = min(new_health / health, 1)
    if power < 1:
        movement.input.vibrate(0.1, power)
    health = new_health
    gui.set_health(health)

func _fire(delta):
    if not gun:
        return
    gun.fire(delta, movement.velocity)

func _footstep_sound():
    if movement.climb_state:
        var ratio = movement.get_ratio_y()
        audio.footstep(ratio)
    else:
        var ratio = movement.get_ratio_x()
        audio.footstep(ratio)

func _input(event):
    if event.is_action_pressed("ui_jump"):
        movement.jump()

    if event.is_action_released("ui_drop"):
        drop_gun()

    if event is InputEventMouseButton:
        if event.button_index == BUTTON_RIGHT and event.pressed:
            movement.jump()

func set_mouth(m = null):
    for n in mouth_node.get_children():
        n.set_visible(false)
    if m == MOUTH_AGGRESIVE:
        mouth_node.get_node("mouth_a").set_visible(true)
    else:
        mouth_node.get_node("mouth_default").set_visible(true)

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