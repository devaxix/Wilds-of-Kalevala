extends Area2D

func _on_body_entered(body):
	if body is PlayerController: # Checks if the overlapping body is your player
		body.has_sword = true
		print("Sword Acquired!")
		# Play a sound effect here if you have one
		queue_free() # Remove the sword from the ground
