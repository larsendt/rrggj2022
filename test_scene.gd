extends Node2D

const SERVER_PORT = 7567
const Player = preload("res://player.tscn")

@onready var multiplayer_info: Label = find_child("MultiplayerInfo")
@onready var player_message_input: LineEdit = find_child("PlayerMessageInput")
@onready var server_message_label: RichTextLabel = find_child("ServerMessageLabel")
@onready var server_message_timer: Timer = find_child("ServerMessageTimer")

var local_player = null

func _ready():
    find_child("PlayerMessageSendButton").pressed.connect(func(): self.send_player_message(player_message_input.text))
    player_message_input.text_submitted.connect(self.send_player_message)
    player_message_input.focus_entered.connect(self._on_player_typing)
    player_message_input.focus_exited.connect(self._on_player_done_typing)
    $PlayerSpawner.spawned.connect(self._on_spawn)
    server_message_timer.timeout.connect(func(): server_message_label.visible = false)

    GameState.player_name_updated.connect(self._update_player_name)
    GameState.player_message_received.connect(self._on_player_message)

    if LocalData.is_server:
        GameState.start_server(LocalData.host_port)
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

    var spawner = await $Spawners.pick_spawner()
    player.global_position = spawner.global_position

    $Players.add_child(player)

func _player_left(id):
    $Players.get_node(str(id)).queue_free()

func _player_joined(id):
    GameState.msg("Peer connected: %d" % id)
    create_player(id)

func _on_spawn(node):
    if str(multiplayer.get_unique_id()) == node.name:
        local_player = node

func _connected_to_server():
    GameState.msg("Connected to the server")
    LocalData.connected = true
    GameState.rpc("rpc_update_player_name", LocalData.player_name)

func _update_player_name(id: int, player_name: String):
    var node = $Players.get_node(str(id))
    if node:
        node.player_name = player_name

func _on_player_message(id: int, m: String):
    $MessageNotificationSound.play()
    if id == 1:
        print("Server sent a message: ", m)
        server_message_label.text = "[color=#777777]Server:[/color] %s" % m
        server_message_label.visible = true
        server_message_timer.start()
        return

    var node = $Players.get_node(str(id))
    if node:
        node.display_message(m)

func send_player_message(msg):
    GameState.rpc("rpc_send_player_message", msg)
    player_message_input.clear()
    player_message_input.release_focus()

func _on_player_typing():
    # this is null on the server
    if local_player:
        local_player.get_node("Input").player_typing = true

func _on_player_done_typing():
    # this is null on the server
    if local_player:
        local_player.get_node("Input").player_typing = false