extends Node2D

const SERVER_PORT = 7567
const MAX_ENEMIES = 8
const Player = preload("res://player.tscn")
const Goblin = preload("res://goblin.tscn")

@onready var multiplayer_info: Label = find_child("MultiplayerInfo")
@onready var player_message_input: LineEdit = find_child("PlayerMessageInput")
@onready var server_message_label: RichTextLabel = find_child("ServerMessageLabel")
@onready var server_message_timer: Timer = find_child("ServerMessageTimer")
@onready var message_log_label: RichTextLabel = find_child("MessageLogLabel")
@onready var connecting_menu: Control = find_child("ConnectingMenu")

var local_player = null

func _ready():
    find_child("PlayerMessageSendButton").pressed.connect(func(): self.send_player_message(player_message_input.text))
    player_message_input.text_submitted.connect(self.send_player_message)
    player_message_input.focus_entered.connect(self._on_player_typing)
    player_message_input.focus_exited.connect(self._on_player_done_typing)
    $PlayerSpawner.spawned.connect(self._on_spawn)
    server_message_timer.timeout.connect(func(): server_message_label.visible = false)

    if multiplayer.get_unique_id() == 1:
        $GobboSpawnTimer.timeout.connect(self.create_gobbo)

    GameState.player_name_updated.connect(self._update_player_name)
    GameState.player_message_received.connect(self._on_player_message)
    GameState.enemy_message_received.connect(self._on_enemy_message)
    GameState.broadcast_message_received.connect(self._on_broadcast_message)

    if LocalData.is_server:
        GameState.start_server(LocalData.host_port)
        GameState.player_joined.connect(self._player_joined)
        GameState.player_left.connect(self._player_left)
        multiplayer_info.text = "Server(%d)" % multiplayer.get_unique_id()
        connecting_menu.visible = false
    else:
        connecting_menu.visible = true
        GameState.join_server(LocalData.client_address, LocalData.client_port)
        GameState.connected_to_server.connect(self._connected_to_server)
        multiplayer_info.text = "Client(%d)" % multiplayer.get_unique_id()

func _input(event):
    if event is InputEventKey:
        if event.pressed and event.keycode == KEY_ESCAPE:
            find_child("EscapeMenu").toggle_escape_menu()

func create_player(id):
    var player = Player.instantiate()
    player.player_name = "Player %d" % id
    player.name = str(id)

    var spawner = await $Spawners.pick_spawner()
    player.global_position = spawner.global_position
    player.find_child("Input").set_multiplayer_authority(id)

    $YSort/Players.add_child(player)

func create_gobbo():
    if multiplayer.get_unique_id() != 1:
        return

    if $YSort/Enemies.get_child_count() >= MAX_ENEMIES:
        return
    
    var spawner = await $Spawners.pick_spawner()
    var goblin = Goblin.instantiate()
    var goblin_name = TextGenerators.generate_goblin_name()
    goblin.name = goblin_name + " " + str(randi())
    goblin.goblin_name = goblin_name
    goblin.global_position = spawner.global_position
    $YSort/Enemies.add_child(goblin)

func _player_left(id):
    $YSort/Players.get_node(str(id)).queue_free()

func _player_joined(id):
    create_player(id)

func _on_spawn(node):
    if str(multiplayer.get_unique_id()) == node.name:
        local_player = node

func _connected_to_server():
    LocalData.connected = true
    connecting_menu.visible = false
    # wooooo race condition
    await get_tree().create_timer(1.0).timeout
    GameState.rpc("rpc_update_player_name", LocalData.player_name)

func _update_player_name(id: int, player_name: String):
    var node = $YSort/Players.get_node(str(id))
    if node:
        node.player_name = player_name

func _on_player_message(id: int, m: String):
    $MessageNotificationSound.play()
    if id == 1:
        server_message_label.text = "[color=#CCCCCC]Server:[/color] %s" % m
        server_message_label.visible = true
        server_message_timer.start()
    else:
        var node = $YSort/Players.get_node(str(id))
        if node:
            node.display_message(m)

    var sender_name
    if id == 1:
        sender_name = "Server"
    elif id in GameState.player_names_by_id:
        sender_name = GameState.player_names_by_id[id]
    else:
        sender_name = "Unk %d" % id

    message_log_label.text += "[color=#999]%s:[/color] %s\n" % [sender_name, m]

func _on_enemy_message(enemy_name: String, m: String):
    $MessageNotificationSound.play()
    message_log_label.text += "[color=#0f0]%s:[/color] %s\n" % [enemy_name, m]

func _on_broadcast_message(_id: int, m: String):
    message_log_label.text += "[color=#999]%s[/color]\n" % m

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
