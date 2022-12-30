extends CharacterBody2D

enum GoblinState {
    IDLING,
    WALKING,
    HURTING,
}

const SPEED = 100.0
const MAX_HEALTH = 10.0

@onready var sprite = $AnimatedSprite2D
@export var goblin_state: GoblinState = GoblinState.IDLING
@export var sync_position: Vector2 = Vector2.ZERO

@export var goblin_name: String = "Snog":
    set(new_name):
        goblin_name = new_name
        $NameLabel.text = new_name

@export var health: float = MAX_HEALTH:
    set(new_health):
        health = new_health
        $FillableBar.current_value = health

var direction: Vector2 = Vector2.ZERO

func _ready():
    $FillableBar.max_value = MAX_HEALTH
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
    self.goblin_state = GoblinState.HURTING
    self.sprite.play("hurt")
    self.direction = Vector2.ZERO
    self.health -= 1
    if self.health <= 0:
        send_message("AAAaaaaaa...")
        queue_free()
    else:
        $NextStateTimer.start(0.5)

func _do_shit_talk():
    send_message(TextGenerators.generate_goblin_message())

func send_message(msg):
    GameState.rpc("rpc_send_enemy_message", self.goblin_name, msg)
    $MessageLabel.text = msg
    $MessageLabel.visible = true
    $MessageTimeoutTimer.start()
    $MessageSendTimer.start(randi_range(15, 60))

func _message_timeout():
    $MessageLabel.visible = false