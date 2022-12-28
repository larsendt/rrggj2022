extends Node

@export var direction = Vector2.ZERO
@export var player_typing: bool = false

func update():
    if player_typing:
        direction = Vector2.ZERO
        return

    var x_dir = Input.get_axis("move_left", "move_right")
    var y_dir = Input.get_axis("move_up", "move_down")
    direction = Vector2(x_dir, y_dir)