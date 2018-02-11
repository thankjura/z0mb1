extends Camera2D

const ZOOM_SPEED = 10

var INIT_ZOOM = Vector2(1,1)

var new_zoom

func _ready():
    INIT_ZOOM = zoom

func area_zoom(area):
    print("new zoom ", area)
    new_zoom = area.get_meta("camera_zoom")

func reset_zoom():
    new_zoom = INIT_ZOOM

func _process(delta):
    if new_zoom and new_zoom != zoom:
        zoom = zoom.linear_interpolate(new_zoom, ZOOM_SPEED * delta)