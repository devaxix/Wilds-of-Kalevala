extends Area2D

func _on_body_entered(body):
	if body.name == "Player":
		# Calls the NEW function we are about to write
		body.unlock_wall_jump_memory() 
		queue_free()
