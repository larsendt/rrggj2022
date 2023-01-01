extends Node

@export var base_goblin_spawn_time: float = 0.25
@export var goblin_spawn_time_multiplier: float = 1.0

@export var base_max_goblins: int = 30
@export var max_goblins_multiplier: float = 1.0

@export var base_goblin_health: float = 2.0
@export var goblin_health_multiplier: float = 1.0


func max_goblins() -> int:
    var minutes = Stats.elapsed_game_time / 60.0
    var addition = 0.5 * minutes
    max_goblins_multiplier = 1.0 + addition
    return int(base_max_goblins * max_goblins_multiplier)


func goblin_spawn_time() -> float:
    var minutes = Stats.elapsed_game_time / 60.0
    var reduction = 0.1 * minutes
    goblin_spawn_time_multiplier = 1.0 - reduction
    if goblin_spawn_time_multiplier < 0.1:
        goblin_spawn_time_multiplier = 0.1
    return base_goblin_spawn_time * goblin_spawn_time_multiplier


func goblin_health() -> float:
    var minutes = Stats.elapsed_game_time / 60.0
    var addition = 0.5 * minutes
    goblin_health_multiplier = 1.0 + addition
    return base_goblin_health * goblin_health_multiplier