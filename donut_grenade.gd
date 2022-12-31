extends Node2D

const Donut = preload("res://donut.tscn")

var projectiles

@export var damage: float = 5.0
@export var max_throw_distance: float = 250.0

func _ready():
    if is_multiplayer_authority():
        $DonutTimer.timeout.connect(self._throw)
        projectiles = get_tree().get_root().get_node("TestScene").find_child("Projectiles")

func _throw():
    var donut: Donut = Donut.instantiate()
    donut.global_position = global_position
    donut.damage = damage
    donut.max_throw_distance = max_throw_distance
    projectiles.add_child(donut, true)