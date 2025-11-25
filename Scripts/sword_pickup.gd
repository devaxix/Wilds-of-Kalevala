extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		body.unlock_sword_memory() # We will make this function next
		queue_free() # The "memory orb" disappears
