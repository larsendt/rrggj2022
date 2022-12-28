extends CharacterBody2D

const SPEED = 150

@export var sync_position: Vector2 = Vector2.ZERO

@export var player_name = "Player ???":
    set(new_name):
        player_name = new_name
        $NameLabel.text = new_name

func _enter_tree():
    $Input/InputSynchronizer.set_multiplayer_authority(str(name).to_int())

func _ready():
    if node_is_locally_controlled():
        $Camera2D.current = true
    else:
        $Camera2D.current = false

func _physics_process(_delta):
    if node_is_locally_controlled():
        $Input.update()

    if is_auth():
        velocity = $Input.direction * SPEED
        move_and_slide()
        sync_position = position
    else:
        position = sync_position


func node_is_locally_controlled():
    # single player or we control this node
    return multiplayer.multiplayer_peer == null or name == str(multiplayer.get_unique_id())

func is_auth():
    return multiplayer.multiplayer_peer == null or is_multiplayer_authority()

func display_message(msg):
    $MessageLabel.text = msg
    $MessageLabel.visible = true
    $MessageTimer.timeout.connect(self.hide_message)
    $MessageTimer.start()

func hide_message():
    $MessageLabel.visible = false
