extends Camera2D

var SPEED = 300.0

func _process(delta):
    if multiplayer.get_unique_id() != 1 or not current:
        return
    var x_dir = Input.get_axis("move_left", "move_right")
    var y_dir = Input.get_axis("move_up", "move_down")
    var direction = Vector2(x_dir, y_dir)
    position += direction * SPEED * delta
