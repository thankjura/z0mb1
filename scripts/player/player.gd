extends KinematicBody2D

var global

var dead
var health = 100
var gui
var gun
var body_scale
var movement

func set_gun(gun_class):
    if gun:
        return false
    gun = gun_class.instance()
    gun.set_name("gun")
    if gun.get_gun_class() == "pistol":
        $anim_aim.play("get_pistol")
    get_node("body/arm_r/hand_r/gun_position").add_child(gun)
    return true

func hit(damage):
    print(damage)
    health -= damage
    _update_health()

func _ready():
    aim = load("res://scripts/player/aim.gd").new(self, $anim_aim)
    movement = load("res://scripts/player/movement.gd").new(self, $anim)
    gui = get_tree().get_root().get_node("world/gui")
    global = get_node("/root/global")
    _update_health()
    body_scale = $body.scale
    aim.look_default(gun)

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
    if jump_count < MAX_JUMP_COUNT and event.is_action_pressed("ui_jump"):
        jump_count += 1
        velocity.y = -JUMP_FORCE

    if event.is_action_released("ui_drop"):
        _drop_gun()



func _physics_process(delta):
    movement._movement_process(delta)

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

    if not gun:
        $anim_aim.stop()

    if movement:
        if gun:
            new_anim = "walk_aim"
        else:
            new_anim = "walk"

        $anim.set_speed_scale(abs(velocity.x*delta))

    else:
        if gun:
            new_anim = "idle_aim"
        else:
            new_anim = "idle"

    if is_on_floor():
        jump_count = 0

    if Input.is_action_pressed("ui_fire"):
        _fire(delta)

#    if get_linear_velocity().y > 0:
#        new_anim = "jump_up"
#    else:
#        new_anim = "jump_down"

    if anim != new_anim:
        anim = new_anim
        $anim.play(anim)