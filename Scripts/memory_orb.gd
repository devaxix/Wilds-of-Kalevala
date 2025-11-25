extends Area2D

func _on_body_entered(body):
	# Check if the player touched me
	if body.name == "Player":
		# Unlock the ability
		body.unlock_sword_memory()
		
		# Optional: Play a sound here!
		
		# Delete this object so it can't be picked up twice
		queue_free()
