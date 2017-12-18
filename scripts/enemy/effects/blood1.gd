extends Node2D

const V = Vector2(1, 0)

func start(obj):
    set_global_position(obj.global_position)
    var angl = V.angle_to(obj.linear_velocity)
    $particles.set_global_rotation(angl)
    if $particles.is_emitting():
        $particles.restart()
    else:
        $particles.set_emitting(true)