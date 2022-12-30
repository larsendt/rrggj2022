extends CharacterBody2D


const SPEED = 100.0
const MAX_HEALTH = 30.0

@onready var sprite = $AnimatedSprite2D
@export var direction: Vector2 = Vector2.ZERO
@export var sync_position: Vector2 = Vector2.ZERO

@export var goblin_name: String = "Snog":
    set(new_name):
        goblin_name = "The Honorable " + new_name
        $NameLabel.text = goblin_name

@export var health: float = MAX_HEALTH:
    set(new_health):
        health = new_health
        if health > 2 * MAX_HEALTH / 3:
            $FillableBar.current_value = health - (2 * MAX_HEALTH / 3);
            $FillableBar2.current_value = MAX_HEALTH / 3
            $FillableBar3.current_value = MAX_HEALTH / 3
        elif health > MAX_HEALTH / 3:
            $FillableBar2.current_value = health - (MAX_HEALTH / 3)
            $FillableBar.current_value = 0
            $FillableBar3.current_value = MAX_HEALTH / 3
        else:
            $FillableBar.current_value = 0
            $FillableBar2.current_value = 0
            $FillableBar3.current_value = health

func _ready():
    $FillableBar.max_value = MAX_HEALTH/3
    $FillableBar2.max_value = MAX_HEALTH/3
    $FillableBar3.max_value = MAX_HEALTH/3

    if is_auth():
        $MessageSendTimer.timeout.connect(self._do_shit_talk)
        $MessageTimeoutTimer.timeout.connect(self._message_timeout)

func _physics_process(_delta):
    if is_auth():
        velocity = direction * SPEED
        move_and_slide()
        sync_position = position
    else:
        position = sync_position

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

func do_hit():
    # self.sprite.play("hurt")
    self.direction = Vector2.ZERO
    self.health -= 1
    if self.health <= 0:
        queue_free()

func _do_shit_talk():
    send_message("...")

func send_message(msg):
    GameState.rpc("rpc_send_enemy_message", self.goblin_name, msg)
    $MessageLabel.text = msg
    $MessageLabel.visible = true
    $MessageTimeoutTimer.start()
    $MessageSendTimer.start(randi_range(15, 60))

func _message_timeout():
    $MessageLabel.visible = false
