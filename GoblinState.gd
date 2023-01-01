extends Node
class_name GoblinState

enum GoblinStateType {
    IDLING,
    WANDERING,
    CHASING,
    ATTACKING,
    FLEEING,
}

enum AreaType {
    SEEK,
    ATTACK,
    FLEE,
}

signal state_updated(new_state: GoblinStateType, target: Area2D)
signal damaged(dmg: int)

var targeted_player: Area2D
var current_state: GoblinStateType = GoblinStateType.IDLING:
    set(new_state):
        current_state = new_state
        if targeted_player != null:
            emit_signal("state_updated", new_state, targeted_player)
        else:
            emit_signal("state_updated", new_state, null)

var other_players: Dictionary


func _ready():
    if is_multiplayer_authority():
        $NextStateTimer.timeout.connect(self._choose_next_state)
        $SeekArea.area_entered.connect(func(player): self._player_entered_area(AreaType.SEEK, player))
        $SeekArea.area_exited.connect(func(player): self._player_exited_area(AreaType.SEEK, player))
        $AttackArea.area_entered.connect(func(player): self._player_entered_area(AreaType.ATTACK, player))
        $AttackArea.area_exited.connect(func(player): self._player_exited_area(AreaType.ATTACK, player))
        $FleeArea.area_entered.connect(func(player): self._player_entered_area(AreaType.FLEE, player))
        $FleeArea.area_exited.connect(func(player): self._player_exited_area(AreaType.FLEE, player))


func _player_entered_area(area_type: AreaType, player: Area2D):
    match area_type:
        AreaType.SEEK:
            if targeted_player == null:
                targeted_player = player
                current_state = GoblinStateType.CHASING
            else:
                other_players[player.name] = player
        AreaType.ATTACK:
            if player == targeted_player:
                current_state = GoblinStateType.ATTACKING
                await get_tree().create_timer(2.0).timeout
                current_state = GoblinStateType.FLEEING
        AreaType.FLEE:
            # no action for entering the FLEE zone
            pass

    
func _player_exited_area(area_type: AreaType, player: Area2D):
    match area_type:
        AreaType.SEEK:
            if player == targeted_player:
                if len(other_players) > 0:
                    targeted_player = choose_dict(other_players)
                    # HACK: don't know if the targeted player is in the chase zone or the attack
                    # zone, so run away first then run back
                    current_state = GoblinStateType.FLEEING
                else:
                    targeted_player = null
                    current_state = GoblinStateType.IDLING
            else:
                other_players.erase(player.name)
        AreaType.FLEE:
            if player == targeted_player:
                current_state = GoblinStateType.CHASING

    
func _choose_next_state():
    if self.current_state == GoblinStateType.IDLING or self.current_state == GoblinStateType.WANDERING:
        if randi() % 2 == 0:
            self.current_state = GoblinStateType.IDLING
        else:
            self.current_state = GoblinStateType.WANDERING


func choose_dict(values: Dictionary):
    return values[values.keys()[randi() % len(values)]]


func choose(values: Array):
    return values[randi() % len(values)]


func do_hit(dmg: int):
    emit_signal("damaged", dmg)
