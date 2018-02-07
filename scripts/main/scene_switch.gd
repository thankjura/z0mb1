extends CanvasLayer

const ANIM_FADE_IN = "fade_in"
const ANIM_FADE_OUT = "fade_out"

var loader = null
var stages_count = 0
var confirm = true
var scene_unloading = false

func _ready():
    $color_rect.hide()
    $anim.connect("animation_finished", self, "_end_animation")
    $button.hide()
    $progress.hide()

func change_scene(path, confirm=true):
    self.confirm = confirm
    scene_unloading = true
    $color_rect.show()
    loader = ResourceLoader.load_interactive(path)
    stages_count = loader.get_stage_count() # WTF
    set_layer(128)
    $anim.play(ANIM_FADE_IN)

func _end_animation(anim_name):
    if anim_name == ANIM_FADE_IN and loader:
        $progress.show()
        get_tree().queue_delete(get_tree().get_current_scene())
        scene_unloading = true

    elif anim_name == ANIM_FADE_OUT:
        _finish()

func _finish():
    set_layer(-1)
    $color_rect.hide()
    $button.hide()
    get_tree().set_pause(false)

func _process(delta):
    if loader:
        if stages_count and $progress.is_visible():
            $progress.set_value(100.0*loader.get_stage()/stages_count)

        if scene_unloading and loader.poll() == ERR_FILE_EOF:
            var scene = loader.get_resource()
            if scene:
                get_tree().change_scene_to(scene)
                loader = null
                stages_count = 0
                $progress.hide()
                if confirm:
                    get_tree().set_pause(true)
                    $button.show()
                    $button.grab_focus()
                else:
                    _finish()

func _on_button_pressed():
    $button.hide()
    get_tree().set_pause(false)
    $anim.play(ANIM_FADE_OUT)
