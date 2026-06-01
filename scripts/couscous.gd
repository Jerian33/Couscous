class_name Couscous
extends CharacterBody2D

signal nap_finished

# Requires Input Map actions: "move_left", "move_right", "jump"

@export var speed: float = 130.0
@export var acceleration: float = 800.0
@export var friction: float = 900.0

## Standing jump — tall arc, less horizontal commitment
@export var stand_jump_velocity: float = -380.0
## Running jump — flatter arc, preserves horizontal momentum
@export var run_jump_velocity: float = -270.0
## Minimum horizontal speed (px/s) to trigger a running jump
@export var run_threshold: float = 60.0
## Horizontal nudge applied during a standing (high) jump
@export var stand_jump_x_boost: float = 50.0

## Dreamflight tuning
@export var flight_speed: float = 120.0
@export var flight_acceleration: float = 600.0
@export var flight_friction: float = 400.0
@export var flight_gravity: float = 80.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var coyote_timer: Timer
var jump_buffer_timer: Timer
var jump_buffered: bool = false
var was_on_floor: bool = false
var is_gnawing: bool = false
var is_digging: bool = false
var is_napping: bool = false

var is_dreamflight: bool = false


func _ready() -> void:
	sprite.animation_finished.connect(_on_animation_finished)
	_configure_jump_timers()


func _on_animation_finished() -> void:
	if sprite.animation == "nap":
		nap_finished.emit()

func _physics_process(delta: float) -> void:
	if is_dreamflight:
		_handle_flight(delta)
		_update_animation()
		move_and_slide()
		return
	_apply_gravity(delta)
	_check_coyote_time()
	_handle_jump()
	_handle_movement(delta)
	_update_animation()
	move_and_slide()


func _handle_flight(delta: float) -> void:
	var dir := Input.get_vector("move_left", "move_right", "flight_up", "flight_down")
	if dir.length() > 0.0:
		velocity = velocity.move_toward(dir * flight_speed, flight_acceleration * delta)
		sprite.flip_h = dir.x < 0
	else:
		velocity.x = move_toward(velocity.x, 0.0, flight_friction * delta)
		velocity.y = move_toward(velocity.y, 0.0, flight_friction * delta)
		velocity.y += flight_gravity * delta


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
func _check_coyote_time() -> void:
	if is_on_floor():
		coyote_timer.stop()
		was_on_floor = true
	elif was_on_floor and coyote_timer.is_stopped():
		coyote_timer.start()
		was_on_floor = false


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or not coyote_timer.is_stopped():
			_jump()
		else:
			jump_buffered = true
			jump_buffer_timer.start()
	elif Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.4
	if jump_buffered and (is_on_floor() or not coyote_timer.is_stopped()):
		_jump()

func _jump() -> void:
	if abs(velocity.x) >= run_threshold:
		velocity.y = run_jump_velocity
	else:
		velocity.y = stand_jump_velocity
		var facing := -1.0 if sprite.flip_h else 1.0
		velocity.x += facing * stand_jump_x_boost
	jump_buffered = false
	jump_buffer_timer.stop()


func _handle_movement(delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
		sprite.flip_h = direction < 0
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)


func _update_animation() -> void:
	var frames := sprite.sprite_frames
	if is_on_floor() and is_gnawing and frames.has_animation("gnaw"):
		sprite.play("gnaw")
	elif is_on_floor() and is_digging and frames.has_animation("dig"):
		sprite.play("dig")
	elif is_on_floor() and is_napping and frames.has_animation("nap"):
		sprite.play("nap")
	elif not is_on_floor():
		if is_dreamflight and frames.has_animation("dreamflight"):
			sprite.play("dreamflight")
		elif velocity.y < 0 and frames.has_animation("high_jump"):
			sprite.play("high_jump")
		elif velocity.y >= 0 and frames.has_animation("fall"):
			sprite.play("fall")
	elif abs(velocity.x) >= run_threshold and frames.has_animation("run"):
		sprite.play("run")
	elif frames.has_animation("idle"):
		sprite.play("idle")


func _configure_jump_timers() -> void:
	coyote_timer = Timer.new()
	coyote_timer.wait_time = 0.1
	coyote_timer.one_shot = true
	add_child(coyote_timer)

	jump_buffer_timer = Timer.new()
	jump_buffer_timer.wait_time = 0.1
	jump_buffer_timer.one_shot = true
	add_child(jump_buffer_timer)
