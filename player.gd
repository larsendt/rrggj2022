extends CharacterBody2D

const SPEED = 150

var sync_position: Vector2 = Vector2.ZERO
var sync_velocity: Vector2 = Vector2.ZERO

var player_name = "Player ???":
    set(new_name):
        player_name = new_name
        $NameLabel.text = new_name

func _enter_tree():
    $Input/InputSynchronizer.set_multiplayer_authority(str(name).to_int())

func _ready():
    $MessageTimer.timeout.connect(self.hide_message)
    if node_is_locally_controlled():
        $Camera2D.current = true
        $NameLabel.add_theme_color_override("font_color", "#00FF33")
    else:
        $Camera2D.current = false

    $Input.weapon_swung.connect(self.server_swing_weapon)


func _physics_process(_delta):
    if node_is_locally_controlled():
        $Input.update()

    if is_auth():
        velocity = $Input.direction * SPEED
        move_and_slide()
        sync_position = position
        sync_velocity = velocity
    else:
        position = sync_position

    # if velocity.length() > 0 and not $StepPlayer.playing:
    #     $StepPlayer.play()
    # elif velocity.length() == 0 and $StepPlayer.playing:
    #     $StepPlayer.stop()

func server_swing_weapon():
    assert(multiplayer.get_unique_id() == 1)
    print("player swing")
    $Weapon.swing()

func node_is_locally_controlled():
    # single player or we control this node
    if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
        return true
    elif multiplayer.multiplayer_peer == null:
        return true
    elif name == str(multiplayer.get_unique_id()):
        return true
    else: 
        return false

func is_auth():
    # single player or we are the authority for this node
    if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
        return true
    elif multiplayer.multiplayer_peer == null:
        return true
    elif is_multiplayer_authority():
        return true
    else: 
        return false

func display_message(msg):
    $MessageLabel.text = msg
    $MessageLabel.visible = true
    $MessageTimer.start()

func hide_message():
    $MessageLabel.visible = false
