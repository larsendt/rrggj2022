extends Node2D
class_name BouleTornado

const Boule = preload("res://boule.tscn")

@export var boule_count: int = 1:
    set(count):
        boule_count = count
        create_boules()

@export var tornado_radius: int = 100:
    set(radius):
        tornado_radius = radius
        for child in get_children():
            child.radius = radius

@export var tornado_speed: float = PI/2:
    set(speed):
        tornado_speed = speed
        for child in get_children():
            child.rotation_speed = speed

@export var damage: float = 1.0:
    set(dmg):
        damage = dmg
        for child in get_children():
            child.damage = damage

func _ready():
    self.tornado_radius = self.tornado_radius
    self.boule_count = self.boule_count

func _physics_process(delta):
    self.transform = self.transform.rotated(self.tornado_speed * delta)

func create_boules():
    for child in get_children():
        child.queue_free()

    var rads_per_boule = 2*PI/boule_count
    for i in range(boule_count):
        var boule = Boule.instantiate()
        boule.radius = tornado_radius
        boule.rotation_speed = tornado_speed
        boule.transform = boule.transform.rotated(i*rads_per_boule)
        add_child(boule)
