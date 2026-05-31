class_name NapSpot
extends Area2D


@onready var sprite: Sprite2D = $Sprite2D

var player_in_range: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("nap") and player_in_range:
		_set_player_napping(true)


func _set_player_napping(value: bool) -> void:
	var bodies := get_overlapping_bodies()
	for body in bodies:
		if body is Couscous:
			body.is_napping = value
			if value:
				body.nap_finished.connect(_on_nap_complete, CONNECT_ONE_SHOT)
			return

## Override in subclasses to add type-specific behavior on completion.
func _on_nap_complete() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body is Couscous:
		player_in_range = true


func _on_body_exited(body: Node2D) -> void:
	if body is Couscous:
		player_in_range = false
