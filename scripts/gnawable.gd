class_name Gnawable
extends StaticBody2D

## Seconds per animation frame while gnawing
@export var seconds_per_frame: float = 0.6

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var blocking_shape: CollisionShape2D = $CollisionShape2D
@onready var interact_zone: Area2D = $InteractZone

var is_gnawed: bool = false
var player_in_range: bool = false
var gnaw_animation: String = ""


func _ready() -> void:
	var fps := 1.0 / seconds_per_frame
	for anim: String in ["from_left", "from_right"]:
		if sprite.sprite_frames.has_animation(anim):
			sprite.sprite_frames.set_animation_speed(anim, fps)
			sprite.sprite_frames.set_animation_loop(anim, false)
	sprite.stop()
	sprite.frame_changed.connect(_on_frame_changed)
	interact_zone.body_entered.connect(_on_body_entered)
	interact_zone.body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if is_gnawed:
		return
	if Input.is_action_pressed("gnaw") and player_in_range:
		if gnaw_animation.is_empty():
			gnaw_animation = "from_left" if _player_is_on_left() else "from_right"
		if not sprite.is_playing():
			sprite.play(gnaw_animation)
		_set_player_gnawing(true)
	else:
		if sprite.is_playing():
			sprite.pause()
		_set_player_gnawing(false)


func _set_player_gnawing(value: bool) -> void:
	var bodies := interact_zone.get_overlapping_bodies()
	for body in bodies:
		if body is Couscous:
			body.is_gnawing = value
			return


func _player_is_on_left() -> bool:
	var bodies := interact_zone.get_overlapping_bodies()
	for body in bodies:
		if body is Couscous:
			return body.global_position.x < global_position.x
	return false


func _on_frame_changed() -> void:
	if gnaw_animation.is_empty():
		return
	var last_frame := sprite.sprite_frames.get_frame_count(gnaw_animation) - 1
	if sprite.frame == last_frame:
		is_gnawed = true
		_set_player_gnawing(false)
		blocking_shape.set_deferred("disabled", true)
		interact_zone.monitoring = false
		_on_gnaw_complete()


## Override in subclasses to add type-specific behavior on completion.
func _on_gnaw_complete() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Couscous:
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body is Couscous:
		player_in_range = false
