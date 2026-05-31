class_name NapSpot_Leaves
extends NapSpot


## Override for level-end nap spot behavior (particles, sound, etc.)
func _on_nap_complete() -> void:
	get_tree().quit()
