extends Area2D

# Export the path so you can change it in the Inspector for each level!
@export_file("*.tscn") var next_level_path

func _on_body_entered(body):
	if body.name == "Player":
		# Use your existing Transition screen!
		TransitionScreen.transition_to_scene(next_level_path)
