extends Node2D
class_name Donut

@export var damage: float
@export var max_throw_distance: float

@onready var sprite: AnimatedSprite2D = find_child("Sprite2D")
@onready var explosion_effect: GPUParticles2D = find_child("DonutExplosion")
@onready var explosion_sound: AudioStreamPlayer2D = find_child("ExplosionSound")
@onready var flash_sound: AudioStreamPlayer2D = find_child("FlashSound")
@onready var smoke_effect: GPUParticles2D = find_child("DonutSmoke")
@onready var collision_shape: CollisionShape2D = find_child("CollisionShape2D")
@onready var goblin_detector: Area2D = find_child("Area2D")

var rng = RandomNumberGenerator.new()
var target: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
    if is_multiplayer_authority():
        goblin_detector.area_entered.connect(self._do_hit)

        rng.randomize()
        var x = rng.randf_range(-1, 1)
        var y = rng.randf_range(-1, 1)
        target = Vector2(x, y).normalized() * rng.randf_range(0.0, max_throw_distance)

        var tween = get_tree().create_tween()
        tween.set_trans(Tween.TRANS_LINEAR)
        tween.tween_property($Path2D/PathFollow2D, "progress_ratio", 1.0, 0.5)
        tween.finished.connect(self._finished_throwing)
        $Path2D.curve.set_point_position(1, target)

func _finished_throwing():
    sprite.play("flashing")
    if Configs.enable_annoying_sounds:
        flash_sound.play()

    await get_tree().create_timer(0.75).timeout

    flash_sound.stop()
    sprite.visible = false

    if Configs.enable_particles:
        explosion_effect.emitting = true
        smoke_effect.emitting = true
        explosion_effect.visible = true
        smoke_effect.visible = true
    
    if Configs.enable_annoying_sounds:
        explosion_sound.play()

    collision_shape.disabled = false

    await get_tree().create_timer(0.25).timeout

    collision_shape.disabled = true
    explosion_effect.visible = false

    await get_tree().create_timer(5.0).timeout
    queue_free()

func _do_hit(area):
    area.get_parent().do_hit(damage)
