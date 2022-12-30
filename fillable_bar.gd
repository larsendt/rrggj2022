extends AnimatedSprite2D

@export var max_value: float = 10:
    set(val):
        max_value = val
        update_bar()

@export var current_value: float = 10:
    set(val):
        current_value = val
        update_bar()

@export var bar_color: Color = Color.MAGENTA:
    set(val):
        bar_color = val
        material.set_shader_parameter("bar_color", val)

func update_bar():
    self.frame = int(10 * self.current_value / self.max_value)

