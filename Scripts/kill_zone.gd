extends Area2D

func _ready():
	# Connect the signal automatically
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the falling object is the player
	if body.name == "Player" or body is PlayerController:
		print("Player fell into the void!")
		if body.has_method("die"):
			body.die()
