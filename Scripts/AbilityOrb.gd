extends Area2D

# 1. Define the list of possible abilities
enum AbilityType { SWORD, WALL_JUMP, DOUBLE_JUMP, DASH }

# 2. SETTINGS (Edit these in the Inspector!)
@export var ability_to_give : AbilityType
@export_multiline var dialogue_lines : Array[String] # <--- NEW: Add text here!

func _on_body_entered(body):
	if body.name == "Player":
		# A. Unlock the Ability
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
		
		# B. Trigger Dialogue (If we added any lines)
		if dialogue_lines.size() > 0:
			# We pass the orb's position so the text box appears above it
			DialogueManager.start_dialogue(global_position, dialogue_lines)
		
		# C. Destroy the Orb
		# (The DialogueManager is separate, so the text will stay even after the orb is gone!)
		queue_free()
