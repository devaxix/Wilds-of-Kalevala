extends Area2D

# 1. Define the list of possible abilities
enum AbilityType { SWORD, WALL_JUMP, DOUBLE_JUMP, DASH }

# 2. SETTINGS
@export var ability_to_give : AbilityType
@export_multiline var dialogue_lines : Array[String]

func _on_body_entered(body):
	if body.name == "Player":
		
		# --- STEP A: CHECK MEMORY ---
		var already_known = false
		
		match ability_to_give:
			AbilityType.SWORD: already_known = GameManager.unlocked_sword
			AbilityType.WALL_JUMP: already_known = GameManager.unlocked_wall_jump
			AbilityType.DOUBLE_JUMP: already_known = GameManager.unlocked_double_jump
			AbilityType.DASH: already_known = GameManager.unlocked_dash

		# --- STEP B: LOGIC SPLIT ---
		if already_known:
			# PATH 1: ALREADY KNOWN (Skip Text)
			_give_ability(body)
			queue_free() 
			
		else:
			# PATH 2: NEW DISCOVERY (Show Text)
			body.set_physics_process(false)
			body.velocity = Vector2.ZERO
			if body.has_node("AnimationPlayer"):
				body.get_node("AnimationPlayer").play("Idle")
			
			if dialogue_lines.size() > 0:
				# --- THE FIX IS HERE ---
				# Removed 'global_position'. Now we just send the lines!
				DialogueManager.start_dialogue(dialogue_lines)
				
				await DialogueManager.dialogue_finished
			
			_give_ability(body)
			body.set_physics_process(true)
			queue_free()

func _give_ability(body):
	match ability_to_give:
		AbilityType.SWORD:
			if body.has_method("unlock_sword_memory"): body.unlock_sword_memory()
		AbilityType.WALL_JUMP:
			if body.has_method("unlock_wall_jump_memory"): body.unlock_wall_jump_memory()
		AbilityType.DOUBLE_JUMP:
			if body.has_method("unlock_double_jump_memory"): body.unlock_double_jump_memory()
		AbilityType.DASH:
			if body.has_method("unlock_dash_memory"): body.unlock_dash_memory()
