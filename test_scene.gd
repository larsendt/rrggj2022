extends Node2D

const SERVER_PORT = 7567
const Player = preload("res://player.tscn")

@onready var multiplayer_info = find_child("MultiplayerInfo")

func _ready():
    $PlayerSpawner.spawned.connect(self._on_spawn)

    if LocalData.is_server:
        GameState.start_server()
        GameState.player_joined.connect(self._player_joined)
        GameState.player_left.connect(self._player_left)
        multiplayer_info.text = "Server(%d)" % multiplayer.get_unique_id()
    else:
        GameState.join_server(LocalData.client_address, LocalData.client_port)
        GameState.connected_to_server.connect(self._connected_to_server)
        multiplayer_info.text = "Client(%d)" % multiplayer.get_unique_id()

func create_player(id):
    var player = Player.instantiate()
    player.player_name = "Player %d" % id
    player.name = str(id)
    $Players.add_child(player)

func _player_left(id):
    $Players.get_node(str(id)).queue_free()

func _player_joined(id):
    GameState.msg("Peer connected: %d" % id)
    create_player(id)

func _on_spawn(node):
    GameState.msg("Spawned %s" % node)

func _connected_to_server():
    GameState.msg("Connected to the server")
    LocalData.connected = true
    GameState.rpc("rpc_update_player_name", LocalData.player_name)
