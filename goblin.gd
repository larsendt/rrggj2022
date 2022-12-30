extends CharacterBody2D

const SHIT_TALK_MESSAGES = [
    "You suck!",
    "Your face sucks!",
    "You walk weird!",
    "You smell!",
]

enum GoblinState {
    IDLING,
    WALKING,
}

const SPEED = 100.0

@onready var sprite = $AnimatedSprite2D
@export var goblin_state: GoblinState = GoblinState.IDLING
@export var sync_position: Vector2 = Vector2.ZERO

var direction: Vector2 = Vector2.ZERO

func _ready():
    if is_auth():
        $MessageSendTimer.timeout.connect(self._do_shit_talk)
        $MessageTimeoutTimer.timeout.connect(self._message_timeout)
        $NextStateTimer.timeout.connect(self._pick_next_state)

func _physics_process(_delta):
    if is_auth():
        velocity = direction * SPEED
        move_and_slide()
        sync_position = position
    else:
        position = sync_position

func _pick_next_state():
    var i = randi() % 3
    match i:
        0:
            self.goblin_state = GoblinState.IDLING
            self.sprite.play("idle")
            self.direction = Vector2.ZERO
        1:
            self.goblin_state = GoblinState.WALKING
            self.sprite.play("walk")
            self.direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

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
    send_message("AAAaaaaa...")
    queue_free()

func _do_shit_talk():
    var msg = SHIT_TALK_MESSAGES[randi() % len(SHIT_TALK_MESSAGES)]
    send_message(msg)

func send_message(msg):
    GameState.rpc("rpc_send_enemy_message", "Gobbo", msg)
    $MessageLabel.text = msg
    $MessageLabel.visible = true
    $MessageTimeoutTimer.start()
    $MessageSendTimer.start(randi_range(5, 15))

func _message_timeout():
    $MessageLabel.visible = false