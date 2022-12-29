extends Node

@export var direction = Vector2.ZERO
@export var player_typing: bool = false

signal weapon_swung

func update():
    if player_typing:
        direction = Vector2.ZERO
        return

    var x_dir = Input.get_axis("move_left", "move_right")
    var y_dir = Input.get_axis("move_up", "move_down")
    direction = Vector2(x_dir, y_dir)

    if Input.is_action_just_pressed("swing_weapon"):
        print(multiplayer.get_unique_id(), " swing")
        rpc_id(1, "rpc_swing_weapon")

@rpc(any_peer, call_remote, reliable)
func rpc_swing_weapon():
    print(multiplayer.get_unique_id(), " got swing RPC")
    emit_signal("weapon_swung")