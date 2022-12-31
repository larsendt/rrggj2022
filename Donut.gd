extends Node2D
class_name Donut

@export var max_throw_distance: float = 250.0
@export var throw_time: float = 1.5
@export var damage: float = 5.0

@onready var sprite: AnimatedSprite2D = find_child("Sprite2D")
@onready var explosion_effect: GPUParticles2D = find_child("DonutExplosion")
@onready var explosion_sound: AudioStreamPlayer2D = find_child("ExplosionSound")
@onready var flash_sound: AudioStreamPlayer2D = find_child("FlashSound")
@onready var smoke_effect: GPUParticles2D = find_child("DonutSmoke")
@onready var collision_shape: CollisionShape2D = find_child("CollisionShape2D")
@onready var goblin_detector: Area2D = find_child("Area2D")

var exploded = false
signal explode

# Called when the node enters the scene tree for the first time.
func _ready():
    if is_multiplayer_authority():
        var target = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(0, max_throw_distance)
        var tween = get_tree().create_tween()
        tween.set_trans(Tween.TRANS_LINEAR)
        tween.tween_property($Path2D/PathFollow2D, "progress_ratio", 1.0, throw_time)
        tween.finished.connect(self._finished_throwing)
        $Path2D.curve.set_point_position(1, target)
        goblin_detector.area_entered.connect(self._do_hit)

func _finished_throwing():
    sprite.play("flashing")
    flash_sound.play()

    await get_tree().create_timer(0.5).timeout

    flash_sound.stop()
    sprite.visible = false
    explosion_effect.emitting = true
    smoke_effect.emitting = true
    explosion_sound.play()
    collision_shape.disabled = false

    await get_tree().create_timer(0.1).timeout

    collision_shape.disabled = true

    await get_tree().create_timer(5.0).timeout
    queue_free()

func _do_hit(area):
    print(multiplayer.get_unique_id(), " donut hit")
    area.get_parent().do_hit(damage)