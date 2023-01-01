extends Node2D

const ExpOrb = preload("res://exp_orb.tscn")
const SPACING = 64

var exps = {}

func add_exp(amt: int, exp_position: Vector2):
    var x = int(exp_position.x / SPACING) * SPACING
    var y = int(exp_position.y / SPACING) * SPACING
    var key = "%s:%s" % [x, y]
    var exp_pos = Vector2(x + randf_range(0, SPACING), y + randf_range(0, SPACING))

    if key in exps:
        var exp_ref = exps[key]
        if exp_ref.get_ref():
            exp_ref.get_ref().value += amt
            return

    rpc("rpc_add_exp", key, amt, exp_pos)

@rpc(authority, call_local, reliable)
func rpc_add_exp(key: String, amt: int, exp_pos: Vector2):
    var orb = ExpOrb.instantiate()
    orb.value = amt
    orb.global_position = exp_pos
    orb.key = key
    exps[key] = weakref(orb)
    add_child(orb)

@rpc(authority, call_local, reliable)
func rpc_remove_exp(key: String):
    var ref = exps[key]
    if ref.get_ref():
        ref.get_ref().queue_free()
        exps.erase(key)