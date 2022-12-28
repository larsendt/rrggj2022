extends Sprite2D

@export var spawner_enabled: bool = true

func _ready():
    $PlayerDetectionArea.body_entered.connect(self._player_entered)
    $PlayerDetectionArea.body_exited.connect(self._player_exited)

func _player_entered(_body):
    print(self, " disabled")
    spawner_enabled = false

func _player_exited(_body):
    print(self, " enabled")
    spawner_enabled = true