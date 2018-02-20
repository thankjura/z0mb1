extends Camera2D

const ZOOM_SPEED = 5

var INIT_ZOOM = Vector2(1,1)
var SHUFFLE_FORCE = -0.8

var new_zoom

var shuffle = 0
var shuffle_time = 0
var shuffle_timeout = 0
var camera_offset = Vector2()

func _ready():
    INIT_ZOOM = zoom
    new_zoom = INIT_ZOOM
    camera_offset = get_offset()

func area_zoom(area):
    new_zoom = INIT_ZOOM * area.get_meta("camera_zoom")

func reset_zoom():
    new_zoom = INIT_ZOOM
    
func shuffle_camera(force, fade_out_time=0.1):
    shuffle = force*pow((new_zoom.y/INIT_ZOOM.y), 2)
    set_offset(Vector2(camera_offset.x, camera_offset.y + shuffle))
    shuffle_timeout = fade_out_time

func _process(delta):
    if new_zoom != zoom:
        zoom = zoom.linear_interpolate(new_zoom, ZOOM_SPEED * delta)
        
    if shuffle_timeout > 0:
        shuffle_timeout -= delta
        if shuffle_timeout <= 0:
            set_offset(camera_offset)
        else:
            shuffle_time += delta
            if shuffle_time > 0.1:
                shuffle *= SHUFFLE_FORCE
                set_offset(Vector2(camera_offset.x, camera_offset.y + shuffle))
                shuffle_time = 0