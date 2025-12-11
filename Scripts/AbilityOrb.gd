extends Area2D

enum AbilityType { SWORD, WALL_JUMP, DOUBLE_JUMP, DASH }

@export var ability_to_give : AbilityType
@export_multiline var dialogue_lines : Array[String]

# --- NODES ---
# USE THIS AS THE PICKUP SOUND REFERENCE
@onready var pickup_sound: AudioStreamPlayer = $PickupSound
@onready var sprite = $AnimatedSprite2D 
@onready var collision = $CollisionShape2D

func _ready():
	# If the direct path failed, try to find it by type/name combination
	if pickup_sound == null:
		if has_node("PickupSound"):
			# Check if the node exists and assign it
			pickup_sound = get_node("PickupSound")
		else:
			# Final fallback: Look for any AudioStreamPlayer child
			for child in get_children():
				if child is AudioStreamPlayer or child is AudioStreamPlayer2D:
					pickup_sound = child
					print("DEBUG: Found Audio Node by TYPE!")
					break
			if pickup_sound == null:
				print("FATAL ERROR: Could not find any AudioStreamPlayer node to use for pickup_sound!")


func _on_body_entered(body):
	if body.name == "Player":
		
		var already_known = false
		
		match ability_to_give:
			AbilityType.SWORD: already_known = GameManager.unlocked_sword
			AbilityType.WALL_JUMP: already_known = GameManager.unlocked_wall_jump
			AbilityType.DOUBLE_JUMP: already_known = GameManager.unlocked_double_jump
			AbilityType.DASH: already_known = GameManager.unlocked_dash

		if already_known:
			_give_ability(body)
			collect_and_destroy()
			
		else:
			body.set_physics_process(false)
			body.velocity = Vector2.ZERO
			if body.has_node("AnimationPlayer"):
				body.get_node("AnimationPlayer").play("Idle")
			
			if dialogue_lines.size() > 0:
				DialogueManager.start_dialogue(dialogue_lines)
				await DialogueManager.dialogue_finished
			
			_give_ability(body)
			body.set_physics_process(true)
			
			collect_and_destroy()

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

func collect_and_destroy():
	print("Attempting to play sound...") 
	
	if sprite: 
		sprite.visible = false
	
	if collision: 
		collision.set_deferred("disabled", true)
	
	if pickup_sound and pickup_sound.stream:
		# 1. Start the sound immediately
		pickup_sound.play()
		print("Sound node found. Playing...") 
		
		# 2. Wait for the sound to finish (if it's long enough)
		if pickup_sound.stream.get_length() > 0.05: # Only await if the sound is longer than 50ms
			await pickup_sound.finished
		else:
			# If the sound is very short, wait a fixed time to guarantee playback
			await get_tree().create_timer(0.2).timeout 
			
		print("Wait period finished. Deleting object.")
	else:
		print("WARNING: PickupSound stream is empty or node is null. Deleting immediately.")
	
	# 4. Delete Object
	queue_free()
