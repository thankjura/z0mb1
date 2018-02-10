extends CanvasLayer

const MENU_SPEED = 20
const MARGIN_H = 40
const MARGIN_V = 20
const INIT_ITEM = null
const PARENT_MENU = "main"

var selected_item
var cursor

var old_transform = Rect2()
var new_transform = Rect2()

var ITEMS

var item_velocity = 0

func _ready():
    set_pause_mode(PAUSE_MODE_PROCESS)
    ITEMS = get_node("panel/items").get_children()
    for i in ITEMS:
        i.connect("focus_entered", self, "_focus_item", [i])
        i.connect("mouse_entered", self, "_mouse_item", [i])
        i.set_default_cursor_shape(Control.CURSOR_POINTING_HAND)
    if INIT_ITEM:
        selected_item = get_node(INIT_ITEM)
    else:
        selected_item = ITEMS[0]

    cursor = get_node("panel/cursor")
    selected_item.grab_focus()
    old_transform = _get_transform()
    new_transform = old_transform
    cursor.set_begin(old_transform.position)
    cursor.set_end(old_transform.size)

func _get_transform():
    var t = selected_item.get_rect()
    var s
    if selected_item is Slider:
        s = selected_item.get_size()
    else:
        s = selected_item.get_minimum_size()
    var begin
    var align = "center"
    if selected_item.has_method("get_align"):
        if selected_item.get_align() == selected_item.ALIGN_LEFT:
            align = "left"
        elif selected_item.get_align() == selected_item.ALIGN_RIGHT:
            align = "right"
    elif selected_item.has_method("get_text_align"):
        if selected_item.get_text_align() == HALIGN_LEFT:
            align = "left"
        elif selected_item.get_text_align() == HALIGN_RIGHT:
            align = "right"

    if align == "left":
        begin = Vector2(t.position.x - MARGIN_H, t.position.y + (t.size.y - s.y) / 2 - MARGIN_V)
    elif align == "right":
        begin = Vector2(t.position.x + t.size.x - s.x - MARGIN_H, t.position.y + (t.size.y - s.y) / 2 - MARGIN_V)
    else:
        begin = Vector2(t.position.x + (t.size.x - s.x) / 2 - MARGIN_H, t.position.y + (t.size.y - s.y) / 2 - MARGIN_V)

    t.position = begin
    t.size = begin + Vector2(s.x + MARGIN_H*2, s.y + MARGIN_V*2)
    return t

func _focus_item(item):
    if selected_item != item:
        selected_item = item
        new_transform = _get_transform()

func _mouse_item(item):
    item.grab_focus()

func _process(delta):
    if new_transform != old_transform:
        if old_transform.position.distance_squared_to(new_transform.position) < 1:
            old_transform = new_transform
            return
        old_transform.position = old_transform.position.linear_interpolate(new_transform.position, MENU_SPEED * delta)
        old_transform.size = old_transform.size.linear_interpolate(new_transform.size, MENU_SPEED * delta)
        cursor.set_begin(old_transform.position)
        cursor.set_end(old_transform.size)


