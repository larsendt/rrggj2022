extends Node2D

const StartScreen = preload("res://start_screen.tscn")

@onready var splash_text_label = find_child("SplashText")

func _ready():
    $TypingTimer.connect("timeout", self._type_splash_text)
    $TransitionTimer.connect("timeout", self._scene_transition)

func _input(event):
    if event is InputEventMouseButton:
        var e = event as InputEventMouseButton
        if e.button_index == MOUSE_BUTTON_LEFT and e.pressed:
            _scene_transition()


func _type_splash_text():
    if splash_text_label.visible_characters >= 9:
        $TypingTimer.stop()
        $TransitionTimer.start()
        return
    splash_text_label.visible_characters += 1

func _scene_transition():
    get_tree().change_scene_to_packed(StartScreen)
