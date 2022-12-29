extends Node

@export var direction: Vector2 = Vector2.ZERO
@export var player_typing: bool = false
@export var cursor_angle: float = 0.0

signal weapon_swung

func update(player_pos: Vector2, cursor_pos: Vector2):
    if player_typing:
        direction = Vector2.ZERO
        return

    var x_dir = Input.get_axis("move_left", "move_right")
    var y_dir = Input.get_axis("move_up", "move_down")
    direction = Vector2(x_dir, y_dir)

    var cursor_dir = player_pos.direction_to(cursor_pos)
    cursor_angle = cursor_dir.angle()
    if Input.is_action_just_pressed("swing_weapon"):
        rpc_id(1, "rpc_swing_weapon")

@rpc(any_peer, call_remote, reliable)
func rpc_swing_weapon():
    emit_signal("weapon_swung")