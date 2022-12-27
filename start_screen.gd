extends Node2D

@onready var player_name_input = find_child("PlayerNameInput")

func _ready():
    find_child("JoinButton").pressed.connect(self._join)
    find_child("HostButton").pressed.connect(self._host)

func _join():
    LocalData.player_name = player_name_input.text
    LocalData.is_server = false
    Scenes.go_to_play_scene()

func _host():
    LocalData.player_name = player_name_input.text
    LocalData.is_server = true
    Scenes.go_to_play_scene()