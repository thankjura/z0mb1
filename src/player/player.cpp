#include <core/Godot.hpp>
#include <KinematicBody2D.hpp>

using namespace godot;

class Test: public GodotScript<KinematicBody2D> {
    GODOT_CLASS(Test);
public:
    Vector2 velocity = Vector2();
    const float GRAVITY = 500;
    const float MAX_FALL_SPEED = 1000;

    Test() {}

    void _physics_process(const float delta) {
        velocity.y += GRAVITY * delta;

        if (velocity.y > MAX_FALL_SPEED) {
            velocity.y = MAX_FALL_SPEED;
        }

        velocity = owner->move_and_slide(velocity);
    }

    static void _register_methods() {
        register_method((char *)"_physics_process", &Test::_physics_process);
    }
};

/** GDNative Initialize **/
extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *o)
{
    godot::Godot::gdnative_init(o);
}

/** GDNative Terminate **/
extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *o)
{
    godot::Godot::gdnative_terminate(o);
}

/** NativeScript Initialize **/
extern "C" void GDN_EXPORT godot_nativescript_init(void *handle)
{
    godot::Godot::nativescript_init(handle);

    godot::register_class<Test>();
}
