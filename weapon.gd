extends Node2D
class_name Weapon

@export var projectile_frequency_multiplier: float = 1.0
@export var additional_projectile_count: int = 0
@export var projectile_damage_multiplier: float = 1.0
@export var projectile_distance_multiplier: float = 1.0

func _ready():
    Stats.stat_updated.connect(self._level_up)

func _level_up(stat_id: String, _value: String):
    if stat_id != Stats.LEVEL_STAT:
        return

    projectile_frequency_multiplier -= 0.1 * Stats.level
    if projectile_frequency_multiplier < 0.1:
        projectile_frequency_multiplier = 0.1

    additional_projectile_count = Stats.level
