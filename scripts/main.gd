extends Node2D

@onready var strawberry_label: Label = $UI/StrawberryLabel


func _ready() -> void:
	GameState.strawberry_collected.connect(_on_strawberry_collected)
	strawberry_label.text = "Strawberries: 0"


func _on_strawberry_collected(new_count: int) -> void:
	strawberry_label.text = "Strawberries: %d" % new_count
