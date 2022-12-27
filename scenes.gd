extends Node

const TestScene = preload("res://test_scene.tscn")
const StartScreen = preload("res://start_screen.tscn")

func go_to_start_scene():
    get_tree().change_scene_to_packed(StartScreen)

func go_to_play_scene():
    get_tree().change_scene_to_packed(TestScene)
