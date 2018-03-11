const GAMEPAD_ID = 0
const DEAD_ZONE_X = 0.1
const DEAD_ZONE_Y = 0.1

var MOVEMENT_MODE = 1
#var

func get_move_vector():
    var up = -1 if Input.is_action_pressed("ui_up") else 0
    var down = 1 if Input.is_action_pressed("ui_down") else 0
    var left = -1 if Input.is_action_pressed("ui_left") else 0
    var right = 1 if Input.is_action_pressed("ui_right") else 0

    var out = Vector2(left+right, up+down)
    var axis_x = Input.get_joy_axis(GAMEPAD_ID, JOY_AXIS_0)
    var axis_y = Input.get_joy_axis(GAMEPAD_ID, JOY_AXIS_1)

    if abs(axis_x) > DEAD_ZONE_X:
        out.x += axis_x

    if abs(axis_y) > DEAD_ZONE_Y:
        out.y += axis_y

    return out.normalized()

func get_direction(player):
    var direction = Vector2()
    if player.gun:
        direction = (player.get_global_mouse_position() - player.gun.get_node("pos").global_position).normalized()
        var dist = abs((player.global_position.x - player.get_global_mouse_position().x))
        if player.get_global_mouse_position().y > player.gun.get_node("pos").global_position.y:
            if dist < player.gun.get("dead_zone/bottom"):
                direction.x = 0
        else:
            if dist < player.gun.get("dead_zone/top"):
                direction.x = 0
    else:
        direction = player.get_global_mouse_position() - player.global_position
    return direction

func vibrate(time, weak=1, strong=1, duration=0.3):
    if Input.is_joy_known(GAMEPAD_ID):
        Input.start_joy_vibration(GAMEPAD_ID, weak, strong, duration)
