extends Node2D

@export var spawner_enabled: bool = true

func _ready():
    $PlayerDetectionArea.body_entered.connect(self._player_entered)
    $PlayerDetectionArea.body_exited.connect(self._player_exited)

func _player_entered(_body):
    spawner_enabled = false

func _player_exited(_body):
    spawner_enabled = true

func do_spawn():
    pass
    #$SpawnSound.play()