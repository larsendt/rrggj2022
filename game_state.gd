extends Node

const DEFAULT_SERVER_PORT = 7567

signal player_joined(id)
signal player_left(id)
signal connected_to_server()
signal disconnected_from_server()

@export var player_names_by_id = {}
@export var player_ids_by_name = {}

signal player_name_updated(id, player_name)
signal broadcast_message_received(id, msg)
signal player_message_received(id, msg)

func start_server(port):
    var peer = ENetMultiplayerPeer.new()
    multiplayer.peer_connected.connect(self._player_joined)
    multiplayer.peer_disconnected.connect(self._player_left)
    peer.create_server(port)
    multiplayer.multiplayer_peer = peer

func join_server(ip_addr, port):
    var peer = ENetMultiplayerPeer.new()
    multiplayer.connected_to_server.connect(func(): emit_signal("connected_to_server"))
    multiplayer.server_disconnected.connect(func(): emit_signal("disconnected_from_server"))
    peer.create_client(ip_addr, port)
    multiplayer.multiplayer_peer = peer

func msg(m):
    rpc("rpc_broadcast_message", m)

@rpc(any_peer, call_remote, reliable, 1)
func rpc_send_player_message(m):
    print("[local: %d] [caller: %d] [say]: %s" % [multiplayer.get_unique_id(), multiplayer.get_remote_sender_id(), m])
    emit_signal("player_message_received", multiplayer.get_remote_sender_id(), m)

@rpc(any_peer, call_local, reliable, 1)
func rpc_broadcast_message(m):
    print("[local: %d] [caller: %d] [broadcast]: %s" % [multiplayer.get_unique_id(), multiplayer.get_remote_sender_id(), m])
    emit_signal("broadcast_message_received", multiplayer.get_remote_sender_id(), m)

@rpc(any_peer, call_local, reliable)
func rpc_update_player_name(player_name):
    var remote_id = multiplayer.get_remote_sender_id()

    var previous_name = player_names_by_id.get(remote_id)
    if previous_name != null and player_name == previous_name:
        if player_ids_by_name[previous_name] != remote_id:
            msg("Name %s is already owned by player %d" % [player_name, player_ids_by_name[previous_name]])

    player_names_by_id[remote_id] = player_name
    player_ids_by_name[player_name] = remote_id
    player_ids_by_name.erase(previous_name)
    msg("Player %d is now named %s" % [remote_id, player_name])
    emit_signal("player_name_updated", remote_id, player_name)

func _player_joined(id):
    var player_name = "Player %d" % id
    player_ids_by_name[name] = id
    player_names_by_id[id] = player_name
    emit_signal("player_joined", id)

func _player_left(id):
    var player_name = player_names_by_id[id]
    player_names_by_id.erase(id)
    player_ids_by_name.erase(player_name)
    emit_signal("player_left", id)