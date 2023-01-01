extends Node2D

const SPEED: float = 400.0

var target: Area2D = null
var key: String

func _ready():
    if multiplayer.is_server():
        $Area2D.area_entered.connect(self._fly_to_player)

@export var value: int = 1:
    set(v):
        value = v
        if v < 5:
            $AnimatedSprite2D.play("grey")
        elif v < 10:
            $AnimatedSprite2D.play("blue")
        elif v < 25:
            $AnimatedSprite2D.play("purple")
        else:
            $AnimatedSprite2D.play("gold")

func _physics_process(delta):
    if target != null:
        var dir = global_position.direction_to(target.global_position)
        var velocity = dir * SPEED * delta
        global_position += velocity

func _fly_to_player(area: Area2D):
    # TODO: remove from parent?
    target = area

func pickup_exp():
    get_parent().rpc("rpc_remove_exp", self.key)
    queue_free()