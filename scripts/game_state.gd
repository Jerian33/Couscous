extends Node

signal strawberry_collected(new_count: int)

var strawberry_count: int = 0


func collect_strawberry() -> void:
	strawberry_count += 1
	strawberry_collected.emit(strawberry_count)
