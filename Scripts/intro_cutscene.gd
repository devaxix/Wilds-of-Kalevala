extends Control

func _ready():
	# 1. Connect to the signal we just made
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	
	# 2. Define your story lines
	var lines: Array[String] = [
		"You open your eyes to the sound of rain.",
		"Something warm had been beside you...",
		"But when you reached for it… it vanished.",
        "What was my name again?"
	]
	
	# 3. Start the dialogue immediately
	# We spawn the box at the bottom-center of the screen
	# (Screen center x = 1920/2, y = 1080 - padding)
	var screen_center = get_viewport_rect().size / 2
	var spawn_pos = Vector2(screen_center.x, 1000) 
	
	DialogueManager.start_dialogue(spawn_pos, lines)

func _on_dialogue_finished():
	# 4. When text is done, switch to Character Select!
	# IMPORTANT: Disconnect the signal so it doesn't trigger again later
	DialogueManager.dialogue_finished.disconnect(_on_dialogue_finished)
	
	TransitionScreen.transition_to_scene("res://Scenes/Areas/character_select.tscn")
