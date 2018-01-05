extends CanvasLayer

var scene_path

func _ready():
    $anim.connect("animation_finished", self, "_finish_anim")

func fade_to(path):
    scene_path = path
    get_node("anim").play("fade_in")    
    $audio.play()

func fade_out():
    scene_path = ""
    get_node("anim").play("fade_out")

func _finish_anim(anim_name):
    if anim_name == "fade_in":
        _change_scene()
        $anim.play("fade_out")

func _change_scene():
    if scene_path:
        get_tree().change_scene(scene_path)