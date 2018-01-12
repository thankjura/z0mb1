extends CanvasLayer

const MENU_SPEED = 10
const MARGIN_H = 40
const MARGIN_V = 20

enum ITEMS {
    resume,
    settings,
    exit
}

var selected_item
var global
var cursor

var old_transform = Rect2()
var new_transform = Rect2()

var item_velocity = 0

func _ready():
    global = get_node("/root/global")
    selected_item = ITEMS.resume
    cursor = get_node("panel/cursor")
    old_transform = _get_transform()
    new_transform = old_transform
    cursor.set_begin(old_transform.position)
    cursor.set_end(old_transform.size)

func _get_transform():
    var node = _get_item_node(selected_item)
    var t = node.get_rect()
    var s = node.get_minimum_size()
    var begin = Vector2(t.position.x + (t.size.x - s.x) / 2 - MARGIN_H, t.position.y - MARGIN_V)
    t.position = begin
    t.size = begin + Vector2(s.x + MARGIN_H*2, s.y + MARGIN_V*2)
    return t

func _get_item_node(item):
    if item == ITEMS.resume:
        return get_node("panel/pause_menu/resume")
    elif item == ITEMS.settings:
        return get_node("panel/pause_menu/settings")
    elif item == ITEMS.exit:
        return get_node("panel/pause_menu/main_menu")
    else:
        return null

func move_cursor(direction):
    if direction:
        selected_item += 1
        if selected_item >= ITEMS.size():
            selected_item = ITEMS.resume
    else:
        selected_item -= 1
        if selected_item < 0:
            selected_item = ITEMS.exit

    new_transform = _get_transform()

func _enter_item():
    if selected_item == ITEMS.resume:
        _exit()

func _exit():
    global.resume()
    queue_free()

func _input(event):
    if event.is_action_pressed("ui_up"):
        move_cursor(false)

    if event.is_action_pressed("ui_down"):
        move_cursor(true)

    if event.is_action_pressed("ui_accept"):
        _enter_item()

func _process(delta):
    if new_transform != old_transform:
        old_transform.position = old_transform.position.linear_interpolate(new_transform.position, MENU_SPEED * delta)
        old_transform.size = old_transform.size.linear_interpolate(new_transform.size, MENU_SPEED * delta)
        cursor.set_begin(old_transform.position)
        cursor.set_end(old_transform.size)


