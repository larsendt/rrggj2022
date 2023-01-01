extends Goblin
class_name BarrelGoblin

func name_prefix() -> String:
    return "The Honorable "

func shit_talk_message() -> String:
    return "..."

func death_message() -> String:
    return "... aaaa..."

func goblin_type() -> String:
    return "barrel"

func initial_health() -> float:
    return 999.0

func do_die():
    send_message(death_message())
    Stats.kills += 1
    Stats.borg_goblins -= 1