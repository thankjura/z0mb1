const GAMEPAD_ID = 0
const DEAD_ZONE_X = 0.1
const DEAD_ZONE_Y = 0.1

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

func vibrate(time, weak=1, strong=1, duration=0.3):
    if Input.is_joy_known(GAMEPAD_ID):
        Input.start_joy_vibration(GAMEPAD_ID, weak, strong, duration)
