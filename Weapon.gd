extends Node2D

var swung: bool = false
var swinging: bool = false

func _ready():
    $SwingAnimation.animation_finished.connect(self._finished_swinging)

func swing():
    if swinging:
        return
    print(multiplayer.get_unique_id(), " doing swing animation")
    if swung:
        $SwingAnimation.play("SwingBack")
    else:
        $SwingAnimation.play("Swing")
    swung = not swung
    swinging = true

func _finished_swinging(_anim_name):
    swinging = false