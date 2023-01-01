extends MarginContainer
class_name Portraits

const PackedGoblinPortrait = preload("res://goblin_portrait.tscn")

func add_portrait(goblin_type: String, node_name: String, goblin_name: String, hp: float, goblin: Goblin) -> GoblinPortrait:
    var p = PackedGoblinPortrait.instantiate()
    p.goblin_name = goblin_name
    p.portrait_type = goblin_type
    p.hp = hp
    p.name = node_name
    p.goblin = goblin
    $ScrollContainer/HBoxContainer.add_child(p)
    if goblin_type == "barrel":
        $ScrollContainer/HBoxContainer.move_child(p,  0)
    return p

func update_hp(goblin_name: String, hp: float):
    var p = $ScrollContainer/HBoxContainer.get_node(goblin_name)
    if not p:
        return
    p.hp = hp
