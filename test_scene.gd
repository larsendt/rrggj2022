extends Node2D

const SERVER_PORT = 7567
const Player = preload("res://player.tscn")

@onready var multiplayer_info = find_child("MultiplayerInfo")

func _ready():
    $PlayerSpawner.spawned.connect(self._on_spawn)

    var peer = ENetMultiplayerPeer.new()
    if LocalData.is_server:
        multiplayer.peer_connected.connect(self._peer_connected)
        peer.create_server(SERVER_PORT)
        multiplayer.multiplayer_peer = peer
        multiplayer_info.text = "Server(%d)" % multiplayer.get_unique_id()
    else:
        multiplayer.connected_to_server.connect(self._connected_to_server)
        peer.create_client("localhost", SERVER_PORT)
        multiplayer.multiplayer_peer = peer
        multiplayer_info.text = "Client(%d)" % multiplayer.get_unique_id()

func create_player(id):
    var player = Player.instantiate()
    player.player_name = "Player %d" % id
    player.name = str(id)
    # player.set_multiplayer_authority(id)
    $Players.add_child(player)

func destroy_player(id):
    $Players.get_node(str(id)).queue_free()

func _peer_connected(id):
    p("Peer connected: %d" % id)
    create_player(id)

func _on_spawn(node):
    p("Spawned %s" % node)

func _connected_to_server():
    p("Connected to the server")
    LocalData.connected = true
    # create_player(multiplayer.get_unique_id())

func p(msg):
    print("%d - %s" % [multiplayer.get_unique_id(), msg])