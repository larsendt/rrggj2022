extends Node

const DEFAULT_SERVER_PORT = 7567

func start_server():
    var peer = ENetMultiplayerPeer.new()
    multiplayer.peer_connected.connect(self._peer_connected)
    peer.create_server(DEFAULT_SERVER_PORT)
    multiplayer.multiplayer_peer = peer

func join_server(ip_addr, port):
    var peer = ENetMultiplayerPeer.new()
    multiplayer.connected_to_server.connect(self._connected_to_server)
    peer.create_client(ip_addr, port)
    multiplayer.multiplayer_peer = peer