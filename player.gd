extends CharacterBody2D
class_name Player

const DonutGrenade = preload("res://donut_grenade.tscn")
const BouleTornado = preload("res://boule_tornado.tscn")
const SPEED = 150

@export var sync_position: Vector2 = Vector2.ZERO
@export var sync_velocity: Vector2 = Vector2.ZERO
@export var sync_cursor_angle: float = 0.0
@export var sync_hurting: bool = false:
    set(hurting):
        sync_hurting = hurting
        if hurting:
            $HurtTimer.start()


var player_name = "Player ???":
    set(new_name):
        player_name = new_name
        $NameLabel.text = new_name


func _enter_tree():
    $Input/InputSynchronizer.set_multiplayer_authority(str(name).to_int())


func _ready():
    $HurtTimer.timeout.connect(func(): sync_hurting = false)
    $MessageTimer.timeout.connect(self.hide_message)

    if multiplayer.is_server():
        $ExpPickupArea.area_entered.connect(self._pickup_exp)

    if node_is_locally_controlled():
        $Camera2D.current = true
        $NameLabel.add_theme_color_override("font_color", "#00FF33")
    else:
        $Camera2D.current = false

    $Input.weapon_swung.connect(self.server_swing_weapon)

    if Configs.enable_weapons:
        var donut = DonutGrenade.instantiate()
        $Weapons.add_child(donut)
        var tornado = BouleTornado.instantiate()
        $Weapons.add_child(tornado)


func _physics_process(delta):
    if node_is_locally_controlled():
        $Input.update(global_position, get_global_mouse_position())

    if is_auth():
        velocity = $Input.direction * SPEED * delta
        move_and_collide(velocity)
        sync_position = position
        sync_velocity = velocity
        sync_cursor_angle = $Input.cursor_angle
    else:
        position = sync_position

    $RedArrow.rotation = sync_cursor_angle
    # $Weapons/Baguette.base_rotation = sync_cursor_angle

    if sync_hurting:
        $PlayerSprite.play("hurt")
    elif sync_velocity.length() > 0:
        $PlayerSprite.play("walk")
    else:
        $PlayerSprite.play("idle")

    if sync_velocity.x > 0:
        $PlayerSprite.flip_h = true
    else:
        $PlayerSprite.flip_h = false

    # if velocity.length() > 0 and not $StepPlayer.playing:
    #     $StepPlayer.play()
    # elif velocity.length() == 0 and $StepPlayer.playing:
    #     $StepPlayer.stop()

func server_swing_weapon():
    assert(multiplayer.get_unique_id() == 1)
    # $Weapons/Baguette.swing()

func node_is_locally_controlled():
    # single player or we control this node
    if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
        return true
    elif multiplayer.multiplayer_peer == null:
        return true
    elif name == str(multiplayer.get_unique_id()):
        return true
    else: 
        return false

func is_auth():
    # single player or we are the authority for this node
    if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
        return true
    elif multiplayer.multiplayer_peer == null:
        return true
    elif is_multiplayer_authority():
        return true
    else: 
        return false

func display_message(msg):
    $MessageLabel.text = msg
    $MessageLabel.visible = true
    $MessageTimer.start()

func hide_message():
    $MessageLabel.visible = false

func do_hit():
    self.sync_hurting = true
    $HurtSound.play()

func _pickup_exp(area: Area2D):
    Stats.experience += area.get_parent().value
    area.get_parent().pickup_exp()
