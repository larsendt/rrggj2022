extends Node

const TIME_STAT = "time"
const PLAYERS_STAT = "players"
const GOBLINS_STAT = "goblins"
const BORG_GOBLINS_STAT = "borg_goblins"
const KILLS_STAT = "kills"
const DAMAGE_DEALT_STAT = "damage_dealt"
const DAMAGE_TAKEN_STAT = "damage_taken"
const EXP_STAT = "exp"
const LEVEL_STAT = "level"

var tracked_stats = {
    TIME_STAT: {"name": "Time", "initial_value": "00:00"},
    PLAYERS_STAT: {"name": "Players", "initial_value": "0"},
    GOBLINS_STAT: {"name": "Goblins", "initial_value": "0"},
    BORG_GOBLINS_STAT: {"name": "Borg Goblins", "initial_value": "0"},
    KILLS_STAT: {"name": "Kills", "initial_value": "0"},
    DAMAGE_DEALT_STAT: {"name": "Damage Dealt", "initial_value": "0"},
    DAMAGE_TAKEN_STAT: {"name": "Damage Taken", "initial_value": "0"},
    EXP_STAT: {"name": "Experience", "initial_value": "0"},
    LEVEL_STAT: {"name": "Level", "initial_value": "0"},
}

signal stat_updated(stat_id: String, value: String)

@export var game_start_time: float = 0.0
@export var elapsed_game_time: float = 0.0

@export var players: int = 0:
    set(val):
        if val != players:
            emit_signal("stat_updated", PLAYERS_STAT, "%d" % val)
        players = val

@export var goblins: int = 0:
    set(val):
        if val != goblins:
            emit_signal("stat_updated", GOBLINS_STAT, "%d" % val)
        goblins = val

@export var borg_goblins: int = 0:
    set(val):
        if val != borg_goblins:
            emit_signal("stat_updated", BORG_GOBLINS_STAT, "%d" % val)
        borg_goblins = val

@export var kills: int = 0:
    set(val):
        if val != kills:
            emit_signal("stat_updated", KILLS_STAT, "%d" % val)
        kills = val

@export var damage_dealt : float = 0.0:
    set(val):
        if val != damage_dealt:
            emit_signal("stat_updated", DAMAGE_DEALT_STAT, "%d" % val)
        damage_dealt = val

@export var damage_taken: float = 0.0:
    set(val):
        if val != damage_taken:
            emit_signal("stat_updated", DAMAGE_TAKEN_STAT, "%d" % val)
        damage_taken = val

var next_level_exp = 10
var per_level_multiplier = 1.5

@export var experience: int = 0:
    set(val):
        if val != experience:
            emit_signal("stat_updated", EXP_STAT, "%d" % val)

        experience = val
        if experience >= next_level_exp:
            level += 1
            next_level_exp = int(next_level_exp * per_level_multiplier)


@export var level: int = 0:
    set(val):
        if val != level:
            emit_signal("stat_updated", LEVEL_STAT, "%d" % val)
        level = val

func _ready():
    if multiplayer.is_server():
        game_start_time = Time.get_unix_time_from_system()

    $TimeUpdateTimer.timeout.connect(self._update_elapsed_time)

func _update_elapsed_time():
    var now = Time.get_unix_time_from_system()
    var delta = now - game_start_time
    if int(delta) == 0:
        return

    elapsed_game_time = delta
    var minutes = int(delta / 60)
    var seconds = delta - (minutes * 60)
    var value = "%02d:%02d" % [minutes, seconds]
    emit_signal("stat_updated", TIME_STAT, value)
