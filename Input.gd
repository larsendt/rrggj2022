extends Node

@export var direction = Vector2.ZERO

func update():
    var x_dir = Input.get_axis("move_left", "move_right")
    var y_dir = Input.get_axis("move_up", "move_down")
    direction = Vector2(x_dir, y_dir)