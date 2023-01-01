extends MarginContainer
class_name GoblinPortrait

@export var hp: float:
    set(new_hp):
        hp = new_hp
        $HPLabel.text = "%d" % hp

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

@export var goblin: Goblin

func _process(_delta):
    var goblin_screen_pos = goblin.get_global_transform_with_canvas() * Vector2.ZERO
    # goblin_screen_pos.y *= -1
    var my_screen_pos = global_position
    var goblin_dir = my_screen_pos.direction_to(goblin_screen_pos)
    $Arrow.rotation = goblin_dir.angle()