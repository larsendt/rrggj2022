extends Node2D
class_name Boule

@export var damage: float = 1.0
@export var rotation_speed: float = PI/2
@export var radius: float = 100.0:
    set(r):
        radius = r
        transform = transform.translated(Vector2(radius, 0.0))

func _ready():
    $Area2D.area_entered.connect(self._boule_hit)

func _physics_process(delta):
    $BouleSprite.transform = $BouleSprite.transform.rotated(2 * rotation_speed * delta)

func _boule_hit(area):
    area.get_parent().do_hit(damage)
