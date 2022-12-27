extends Node2D

@onready var splash_text_label = $CanvasLayer/MarginContainer/SplashText

func _ready():
    $TypingTimer.connect("timeout", self._type_splash_text)
    $TransitionTimer.connect("timeout", self._scene_transition)

func _type_splash_text():
    if splash_text_label.visible_characters >= 9:
        $TypingTimer.stop()
        $TransitionTimer.start()
        return
    splash_text_label.visible_characters += 1

func _scene_transition():
    Scenes.go_to_start_scene()