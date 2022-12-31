extends Node2D

const TestScene = preload("res://test_scene.tscn")

@onready var player_name_input = find_child("PlayerNameInput")
@onready var host_port_input = find_child("HostPortInput")
@onready var client_address_input = find_child("ClientAddressInput")
@onready var client_port_input = find_child("ClientPortInput")

@onready var enable_particles = find_child("EnableParticles")
@onready var enable_annoying_sounds = find_child("EnableAnnoyingSounds")
@onready var enable_weapons = find_child("EnableWeapons")
@onready var enable_messages = find_child("EnableMessages")
@onready var enable_enemies = find_child("EnableEnemies")
@onready var mega_projectiles = find_child("MegaProjectiles")

func _ready():
    find_child("JoinButton").pressed.connect(self._join)
    find_child("HostButton").pressed.connect(self._host)

    host_port_input.text = str(GameState.DEFAULT_SERVER_PORT)
    client_port_input.text = str(GameState.DEFAULT_SERVER_PORT)
    client_address_input.text = "127.0.0.1"

    enable_particles.toggled.connect(func(enable): Configs.enable_particles = enable)
    enable_annoying_sounds.toggled.connect(func(enable): Configs.enable_annoying_sounds = enable)
    enable_weapons.toggled.connect(func(enable): Configs.enable_weapons = enable)
    enable_messages.toggled.connect(func(enable): Configs.enable_messages = enable)
    enable_enemies.toggled.connect(func(enable): Configs.enable_enemies = enable)
    mega_projectiles.toggled.connect(func(enable): Configs.mega_projectiles = enable)

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
