extends Weapon

const Donut = preload("res://donut.tscn")

@onready var scene_root = $"/root/TestScene"

@export var damage: float = 2.0
@export var projectile_count: int = 1
@export var max_throw_distance: float = 250.0
@export var projectile_throw_time: float = 3.0

func _ready():
    if Configs.mega_projectiles:
        projectile_frequency_multiplier = 0.1 
        additional_projectile_count = 5

    if is_multiplayer_authority():
        $DonutTimer.timeout.connect(self._throw)
        $DonutTimer.start(projectile_throw_time * projectile_frequency_multiplier)

func _throw():
    for i in range(projectile_count + additional_projectile_count):
        var _damage = damage * projectile_damage_multiplier
        var _max_throw_distance = max_throw_distance * projectile_distance_multiplier
        var properties = {"damage": _damage, "max_throw_distance": _max_throw_distance}
        var _name = "Donut" + str(randi())
        scene_root.rpc("spawn_projectile", "donut", global_position, _name, properties)
        await get_tree().create_timer(0.1).timeout

    $DonutTimer.start(projectile_throw_time * projectile_frequency_multiplier)