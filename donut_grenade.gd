extends Weapon

const Donut = preload("res://donut.tscn")

var projectiles

@export var damage: float = 2.0
@export var projectile_count: int = 1
@export var max_throw_distance: float = 250.0
@export var projectile_throw_time: float = 3.0

func _ready():
    if is_multiplayer_authority():
        $DonutTimer.timeout.connect(self._throw)
        $DonutTimer.start(projectile_throw_time * projectile_frequency_multiplier)
        projectiles = get_tree().get_root().get_node("TestScene").find_child("Projectiles")

func _throw():
    for i in range(projectile_count + additional_projectile_count):
        var donut: Donut = Donut.instantiate()
        donut.name = "Donut" + str(randi())
        donut.global_position = global_position
        donut.damage = damage * projectile_damage_multiplier
        donut.max_throw_distance = max_throw_distance * projectile_distance_multiplier
        projectiles.add_child(donut, true)
        await get_tree().create_timer(0.05).timeout

    $DonutTimer.start(projectile_throw_time * projectile_frequency_multiplier)