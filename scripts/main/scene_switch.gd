extends CanvasLayer

var scene

func simple(scene_or_path):
    set_layer(128)
    if typeof(scene_or_path) in [4, 16]:
        scene = load(scene_or_path)
    else:
        scene = scene_or_path

    $anim.stop()
    $anim.play("simple")
    $audio.play()

func _end():
    set_layer(-1)

func _change_scene():
    if scene:
        get_tree().get_current_scene().queue_free()
        get_tree().change_scene_to(scene)
        scene = null