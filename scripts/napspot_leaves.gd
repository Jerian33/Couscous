class_name NapSpot_Leaves
extends NapSpot


## Override for level-end nap spot behavior (particles, sound, etc.)
func _on_nap_complete() -> void:
	GameState.is_dream = true
	get_tree().change_scene_to_file("res://flight_test.tscn")
