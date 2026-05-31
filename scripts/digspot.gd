class_name DigSpot
extends Area2D


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var left_particles : GPUParticles2D = $AnimatedSprite2D/LeftParticles
@onready var right_particles : GPUParticles2D = $AnimatedSprite2D/RightParticles


var is_dug: bool = false
var player_in_range: bool = false
var dig_animation: String = "dig_out"

func _ready() -> void:
	sprite.stop()
	sprite.frame_changed.connect(_on_frame_changed)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if is_dug:
		return
	if Input.is_action_pressed("dig") and player_in_range:
		if not sprite.is_playing():
			sprite.play(dig_animation)
		left_particles.emitting = true
		right_particles.emitting = true
		_set_player_digging(true)
	else:
		if sprite.is_playing():
			sprite.pause()
		_set_player_digging(false)
		left_particles.emitting = false
		right_particles.emitting = false


func _set_player_digging(value: bool) -> void:
	var bodies := get_overlapping_bodies()
	for body in bodies:
		if body is Couscous:
			body.is_digging = value
			return


func _on_frame_changed() -> void:
	if dig_animation.is_empty():
		return
	var last_frame := sprite.sprite_frames.get_frame_count(dig_animation) - 1
	if sprite.frame == last_frame:
		is_dug = true
		_set_player_digging(false)
		monitoring = false
		_on_dig_complete()
		left_particles.emitting = false
		right_particles.emitting = false


func _on_dig_complete() -> void:
	pass ## Override in sublcasses


func _on_body_entered(body: Node2D) -> void:
	if body is Couscous:
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body is Couscous:
		player_in_range = false
