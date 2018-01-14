extends CanvasLayer

var scene_path

func simple(path):
    set_layer(128)
    scene_path = path
    $anim.stop()
    $anim.play("simple")
    $audio.play()

func _end():
    set_layer(-1)

func _change_scene():
    if scene_path:
        get_tree().get_current_scene().queue_free()
        get_tree().change_scene(scene_path)
        scene_path = ""