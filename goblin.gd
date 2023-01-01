extends CharacterBody2D

class_name Goblin

const DEFAULT_SPEED = 100.0
const RUN_SPEED = 150.0
const FLEE_SPEED = 250.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var portraits: Portraits = get_tree().get_root().get_node("TestScene").find_child("Portraits")
@export var sync_position: Vector2 = Vector2.ZERO
@export var initial_global_position: Vector2 = Vector2.ZERO

@export var goblin_name: String = "Snog":
    set(new_name):
        goblin_name = name_prefix() + new_name
        $NameLabel.text = goblin_name

@export var health: float = initial_health():
    set(new_health):
        health = new_health
        # if new_health < 5:
        #     SPEED = DEFAULT_SPEED * 3
        #     $AnimatedSprite2D.speed_scale = 3.0
        # else:
        #     SPEED = DEFAULT_SPEED
        #     $AnimatedSprite2D.speed_scale = 1.0
        $FillableBar.current_value = health

var direction: Vector2 = Vector2.ZERO
var target: Node2D = null
var portrait: GoblinPortrait
var speed = DEFAULT_SPEED

########## Overridable Stuff ##############

func name_prefix() -> String:
    return ""

func short_goblin_name() -> String:
    return goblin_name.replace("The Honorable ", "")

func shit_talk_message() -> String:
    return TextGenerators.generate_goblin_message()

func death_message() -> String:
    return "AAAAAAAAAAAAAaaaaa..."

func goblin_type() -> String:
    return "basic"

func initial_health() -> float:
    return Modifiers.goblin_health()

func exp_amt() -> int:
    return 1

func do_die():
    send_message(death_message())
    Stats.kills += 1
    Stats.goblins -= 1


######## End Overridable Stuff ###########

func _ready():
    #portraits.add_portrait(goblin_type(), self.name, self.short_goblin_name(), self.health, self)

    # global_position = initial_global_position

    $FillableBar.max_value = initial_health()
    if is_auth():
        $GoblinState.state_updated.connect(self._state_updated)
        $GoblinState.damaged.connect(self.do_hit)
        $MessageSendTimer.timeout.connect(self._do_shit_talk)
        $MessageTimeoutTimer.timeout.connect(self._message_timeout)

func _physics_process(_delta):
    if is_auth():
        var dir
        if self.target == null:
            dir = direction
        elif $GoblinState.current_state == GoblinState.GoblinStateType.FLEEING:
            dir = self.global_position.direction_to(target.global_position)
            # run awayyyyyyyyyyy
            dir *= -1
        else:
            dir = self.global_position.direction_to(target.global_position)

        velocity = dir * speed #* delta

        if velocity.x > 0:
            $AnimatedSprite2D.flip_h = true
        else:
            $AnimatedSprite2D.flip_h = false

        move_and_slide()
        sync_position = position
    else:
        position = sync_position

func _state_updated(new_state: GoblinState.GoblinStateType, _target: Node2D):
    match new_state:
        GoblinState.GoblinStateType.WANDERING:
            self.sprite.play("walk")
            self.sprite.speed_scale = 1.0
            speed = DEFAULT_SPEED
            direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
            self.target = null
        GoblinState.GoblinStateType.IDLING:
            self.sprite.play("idle")
            self.sprite.speed_scale = 1.0
            speed = DEFAULT_SPEED
            direction = Vector2.ZERO
            self.target = null
        GoblinState.GoblinStateType.CHASING:
            self.sprite.play("walk")
            self.sprite.speed_scale = 1.5
            speed = RUN_SPEED
            direction = Vector2.ZERO
            self.target = _target
        GoblinState.GoblinStateType.ATTACKING:
            self.sprite.play("walk")
            self.sprite.speed_scale = 3.0
            speed = RUN_SPEED
            direction = Vector2.ZERO
            self.target = _target
        GoblinState.GoblinStateType.FLEEING:
            self.sprite.play("walk")
            self.sprite.speed_scale = 3.0
            speed = FLEE_SPEED
            direction = Vector2.ZERO
            self.target = _target

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

func do_hit(dmg: float):
    var current_animation = sprite.animation
    self.sprite.play("hurt")

    self.health -= dmg
    Stats.damage_dealt += dmg

    if self.health < 0:
        self.health = 0

    await get_tree().create_timer(0.5).timeout
    self.sprite.play(current_animation)

    #portraits.update_hp(self.name, self.health)

    if self.health <= 0:
        do_die()
        get_tree().get_root().get_node("TestScene").add_exp(exp_amt(), global_position)
        queue_free()

func _do_shit_talk():
    send_message(shit_talk_message())

func send_message(msg):
    GameState.rpc("rpc_send_enemy_message", self.goblin_name, msg)
    $MessageLabel.text = msg
    $MessageLabel.visible = true
    $MessageTimeoutTimer.start()
    $MessageSendTimer.start(randi_range(15, 60))

func _message_timeout():
    $MessageLabel.visible = false
