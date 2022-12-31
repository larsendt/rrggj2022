extends Node2D

var swung: bool = false
var swinging: bool = false
@export var damage: float = 1.0
@export var base_rotation: float = 0.0
@export var swing_rotation: float = 0.0

func _ready():
    $SwingAnimation.animation_finished.connect(self._finished_swinging)
    if multiplayer.get_unique_id() == 1:
        $Area2D.area_entered.connect(self._area_entered)

func _physics_process(_delta):
    rotation = base_rotation + swing_rotation - (PI/2)

func swing():
    var suffix
    if swinging:
        return

    if swung:
        suffix = "Back"
    else:
        suffix = ""

    $SwingAnimation.play("Swing" + suffix)
    swung = not swung
    swinging = true

func _finished_swinging(_anim_name):
    swinging = false

func _area_entered(area):
    area.get_parent().do_hit(damage)
