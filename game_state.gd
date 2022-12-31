extends Node

const DEFAULT_SERVER_PORT = 7567

signal player_joined(id)
signal player_left(id)
signal connected_to_server()
signal disconnected_from_server()

@export var player_names_by_id = {}
@export var player_ids_by_name = {}
var server_message_log = []

signal player_name_updated(id: int, player_name: String)
signal broadcast_message_received(id:, msg: String)
signal player_message_received(id: int, msg: String)
signal enemy_message_received(name: String, msg: String)

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

@rpc(any_peer, call_local, reliable, 1)
func rpc_send_player_message(m):
    if not Configs.enable_messages:
        return
    print("[local: %d] [caller: %d] [say]: %s" % [multiplayer.get_unique_id(), multiplayer.get_remote_sender_id(), m])
    emit_signal("player_message_received", multiplayer.get_remote_sender_id(), m)
    if multiplayer.get_unique_id() == 1:
        server_message_log.push_back(["player_message", multiplayer.get_remote_sender_id(), m])

@rpc(authority, call_local, reliable, 1)
func rpc_send_enemy_message(enemy_name, m):
    if not Configs.enable_messages:
        return
    emit_signal("enemy_message_received", enemy_name, m)
    if multiplayer.get_unique_id() == 1:
        server_message_log.push_back(["enemy_message", enemy_name, m])

@rpc(any_peer, call_local, reliable, 1)
func rpc_broadcast_message(m):
    if not Configs.enable_messages:
        return
    print("[local: %d] [caller: %d] [broadcast]: %s" % [multiplayer.get_unique_id(), multiplayer.get_remote_sender_id(), m])
    emit_signal("broadcast_message_received", multiplayer.get_remote_sender_id(), m)
    if multiplayer.get_unique_id() == 1:
        server_message_log.push_back(["broadcast_message", multiplayer.get_remote_sender_id(), m])

@rpc(any_peer, call_local, reliable)
func rpc_update_player_name(player_name):
    if not Configs.enable_messages:
        return

    if player_name == "server" or player_name == "Server":
        msg("Can't pick the name 'Server'")
        return

    var remote_id = multiplayer.get_remote_sender_id()

    var previous_name = player_names_by_id.get(remote_id)
    if previous_name != null and player_name == previous_name:
        if player_ids_by_name[previous_name] != remote_id:
            msg("Name %s is already owned by player %d" % [player_name, player_ids_by_name[previous_name]])
            return

    player_names_by_id[remote_id] = player_name
    player_ids_by_name[player_name] = remote_id
    player_ids_by_name.erase(previous_name)
    if multiplayer.get_unique_id() == 1:
        msg("Player %d is now named %s" % [remote_id, player_name])
    emit_signal("player_name_updated", remote_id, player_name)

@rpc(authority, call_remote, reliable)
func backfill_message_log(message_log):
    if not Configs.enable_messages:
        return

    for row in message_log:
        if row[0] == "broadcast_message":
            emit_signal("broadcast_message_received", row[1], row[2])
        elif row[0] == "player_message":
            emit_signal("player_message_received", row[1], row[2])
        elif row[0] == "enemy_message":
            emit_signal("enemy_message_received", row[1], row[2])
        else:
            print("Unknown backfill type ", row)

@rpc(authority, call_remote, reliable)
func backfill_player_names(new_player_names_by_id):
    if not Configs.enable_messages:
        return

    for id in new_player_names_by_id:
        if id == multiplayer.get_unique_id():
            # don't update our own name
            continue

        var player_name = new_player_names_by_id[id]
        emit_signal("player_name_updated", id, player_name)
        player_names_by_id[id] = player_name 
        player_ids_by_name[player_name] = id

func _player_joined(id):
    var player_name = "Player %d" % id
    player_ids_by_name[player_name] = id
    player_names_by_id[id] = player_name
    # race condition?
    # await get_tree().create_timer(0.5).timeout
    emit_signal("player_joined", id)
    rpc_id(id, "backfill_message_log", server_message_log)
    rpc_id(id, "backfill_player_names", player_names_by_id)
    msg("Player %s joined" % [id])

func _player_left(id):
    var player_name = player_names_by_id[id]
    player_names_by_id.erase(id)
    player_ids_by_name.erase(player_name)
    emit_signal("player_left", id)
