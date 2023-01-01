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
    return 99.0

func do_die():
    send_message(death_message())
    Stats.kills += 1
    Stats.borg_goblins -= 1

func exp_amt() -> int:
    return 25

func _ready():
    super()
    portraits.add_portrait(goblin_type(), self.name, self.short_goblin_name(), self.health, self)

func do_hit(dmg: float):
    super(dmg)
    portraits.update_hp(self.name, self.health)