extends Node2D

var swung: bool = false
var swinging: bool = false

func _ready():
    $SwingAnimation.animation_finished.connect(self._finished_swinging)
    if multiplayer.get_unique_id() == 1:
        $Area2D.area_entered.connect(self._area_entered)

func swing(cursor_angle):
    var prefix
    var suffix
    if swinging:
        return

    if swung:
        suffix = "Back"
    else:
        suffix = ""

    if (cursor_angle > 0 and cursor_angle < PI/4) or (cursor_angle < 0 and cursor_angle > -PI/4):
        prefix = "Right"
    elif cursor_angle < -PI/4 and cursor_angle > -3*PI/4:
        prefix = "Top"
    elif cursor_angle < -3*PI/4 or cursor_angle > 3*PI/4:
        prefix = "Left"
    else:
        prefix = "Bottom"

    $SwingAnimation.play(prefix + "Swing" + suffix)
    swung = not swung
    swinging = true

func _finished_swinging(_anim_name):
    swinging = false

func _area_entered(area):
    if area.get_parent() != get_parent():
        # not us
        area.get_parent().do_hit()
