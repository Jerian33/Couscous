class_name Strawberry
extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Couscous:
		GameState.collect_strawberry()
		queue_free()
