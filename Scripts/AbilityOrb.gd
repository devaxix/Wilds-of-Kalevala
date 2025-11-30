extends Area2D

# 1. Define the list of possible abilities
enum AbilityType { SWORD, WALL_JUMP, DOUBLE_JUMP, DASH }

# 2. Create a dropdown menu in the Inspector
@export var ability_to_give : AbilityType

# 3. Connect this signal using the Node tab, or keep the default name
func _on_body_entered(body):
	if body.name == "Player":
		match ability_to_give:
			AbilityType.SWORD:
				if body.has_method("unlock_sword_memory"):
					body.unlock_sword_memory()
			AbilityType.WALL_JUMP:
				if body.has_method("unlock_wall_jump_memory"):
					body.unlock_wall_jump_memory()
			AbilityType.DOUBLE_JUMP:
				if body.has_method("unlock_double_jump_memory"):
					body.unlock_double_jump_memory()
			AbilityType.DASH:
				if body.has_method("unlock_dash_memory"):
					body.unlock_dash_memory()
		
		# Optional: Play a sound here before deleting
		queue_free()
