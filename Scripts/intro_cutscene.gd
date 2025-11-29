extends Control

var lines: Array[String] = [
	"You open your eyes to the sound of rain.",
	"Something warm had been beside you...",
	"But when you reached for it... it vanished.",
	"Only the echo of its warmth lingers.",
	"What was my name again?"
]

func _ready():
	# Connect to the manager's signal
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	
	# Start after a tiny delay to ensure the scene is loaded
	await get_tree().create_timer(0.5).timeout
	
	# Spawn box at bottom-center
	var screen_center = get_viewport_rect().size / 2
	# Assuming 1080p height, 900 puts it near the bottom
	var spawn_pos = Vector2(screen_center.x, 900) 
	
	DialogueManager.start_dialogue(spawn_pos, lines)

# --- THE FIX: Use _input, NOT _process ---
# This ensures one click = one action
func _input(event):
	# If player clicks OR presses Space/Enter
	if event.is_action_pressed("Attack") or event.is_action_pressed("Jump") or event is InputEventMouseButton:
		if event.is_pressed() and not event.is_echo():
			# We don't need to do anything here!
			# The DialogueManager handles the input automatically because
			# we set it up to listen for inputs in its own script.
			pass

func _on_dialogue_finished():
	DialogueManager.dialogue_finished.disconnect(_on_dialogue_finished)
	TransitionScreen.transition_to_scene("res://Scenes/Areas/character_select.tscn")
