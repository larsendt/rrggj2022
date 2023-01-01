extends Node

const TIME_STAT = "time"
const PLAYERS_STAT = "players"
const GOBLINS_STAT = "goblins"
const BORG_GOBLINS_STAT = "borg_goblins"
const KILLS_STAT = "kills"
const DAMAGE_DEALT_STAT = "damage_dealt"
const DAMAGE_TAKEN_STAT = "damage_taken"

var tracked_stats = {
    TIME_STAT: {"name": "Time", "initial_value": "00:00"},
    PLAYERS_STAT: {"name": "Players", "initial_value": "0"},
    GOBLINS_STAT: {"name": "Goblins", "initial_value": "0"},
    BORG_GOBLINS_STAT: {"name": "Borg Goblins", "initial_value": "0"},
    KILLS_STAT: {"name": "Kills", "initial_value": "0"},
    DAMAGE_DEALT_STAT: {"name": "Damage Dealt", "initial_value": "0"},
    DAMAGE_TAKEN_STAT: {"name": "Damage Taken", "initial_value": "0"},
}

signal stat_updated(stat_id: String, value: String)

@export var game_start_time: float = 0

@export var players: int = 0:
    set(val):
        players = val
        emit_signal("stat_updated", PLAYERS_STAT, "%d" % val)

@export var goblins: int = 0:
    set(val):
        goblins = val
        emit_signal("stat_updated", GOBLINS_STAT, "%d" % val)

@export var borg_goblins: int = 0:
    set(val):
        borg_goblins = val
        emit_signal("stat_updated", BORG_GOBLINS_STAT, "%d" % val)

@export var kills: int = 0:
    set(val):
        kills = val
        emit_signal("stat_updated", KILLS_STAT, "%d" % val)

@export var damage_dealt : float = 0.0:
    set(val):
        damage_dealt = val
        emit_signal("stat_updated", DAMAGE_DEALT_STAT, "%d" % val)

@export var damage_taken: float = 0.0:
    set(val):
        damage_taken = val
        emit_signal("stat_updated", DAMAGE_TAKEN_STAT, "%d" % val)

func _ready():
    if multiplayer.is_server():
        game_start_time = Time.get_unix_time_from_system()

    $TimeUpdateTimer.timeout.connect(self._update_elapsed_time)

func _update_elapsed_time():
    var now = Time.get_unix_time_from_system()
    var delta = now - game_start_time
    var minutes = int(delta / 60)
    var seconds = delta - (minutes * 60)
    var value = "%02d:%02d" % [minutes, seconds]
    emit_signal("stat_updated", TIME_STAT, value)
