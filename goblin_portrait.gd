extends MarginContainer
class_name GoblinPortrait

@export var hp: float:
    set(new_hp):
        hp = new_hp
        var hpval = hp
        if hpval < 1:
            hpval = 1
        $HPLabel.text = "%d" % hpval

@export var goblin_name: String:
    set(new_name):
        goblin_name = new_name
        $VBoxContainer/NameLabel.text = goblin_name

@export var portrait_type: String:
    set(p):
        portrait_type = p
        match p:
            "basic":
                $VBoxContainer/BasicPortrait.visible = true
                $VBoxContainer/BarrelPortrait.visible = false
            "barrel":
                $VBoxContainer/BasicPortrait.visible = false
                $VBoxContainer/BarrelPortrait.visible = true 

var weak_goblin: WeakRef
@export var goblin: Goblin:
    set(gobbo):
        goblin = gobbo
        weak_goblin = weakref(goblin)

func _process(_delta):
    if not weak_goblin.get_ref():
        queue_free()
        return

    var goblin_screen_pos = weak_goblin.get_ref().get_global_transform_with_canvas() * Vector2.ZERO
    var my_screen_pos = global_position
    var goblin_dir = my_screen_pos.direction_to(goblin_screen_pos)
    $Arrow.rotation = goblin_dir.angle()