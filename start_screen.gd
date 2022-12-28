extends Node2D

const TestScene = preload("res://test_scene.tscn")

@onready var player_name_input = find_child("PlayerNameInput")
@onready var host_port_input = find_child("HostPortInput")
@onready var client_address_input = find_child("ClientAddressInput")
@onready var client_port_input = find_child("ClientPortInput")

func _ready():
    find_child("JoinButton").pressed.connect(self._join)
    find_child("HostButton").pressed.connect(self._host)

    host_port_input.text = str(GameState.DEFAULT_SERVER_PORT)
    client_port_input.text = str(GameState.DEFAULT_SERVER_PORT)
    client_address_input.text = "127.0.0.1"

func _join():
    if not client_address_input.text.is_valid_ip_address():
        print("Invalid IP address ", client_address_input.text)
        return

    if not str(client_port_input.text).is_valid_int():
        print("Invalid port ", client_port_input.text)
        return

    if len(player_name_input.text) == 0:
        print("Invalid player name ", player_name_input.text)
        return

    LocalData.player_name = player_name_input.text
    LocalData.is_server = false
    LocalData.client_address = client_address_input.text
    LocalData.client_port = client_port_input.text.to_int()
    get_tree().change_scene_to_packed(TestScene)

func _host():
    if not str(host_port_input.text).is_valid_int():
        print("Invalid port ", host_port_input.text)
        return

    LocalData.is_server = true
    LocalData.host_port = host_port_input.text.to_int()
    get_tree().change_scene_to_packed(TestScene)
