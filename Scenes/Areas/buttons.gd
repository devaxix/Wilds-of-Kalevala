extends Node2D

# Correct path: 'clickingsound' is a direct child and all lowercase.
@onready var click_sound = $"clickingsound" 


func _ready():
	# Loop through all children of the Buttons container to connect the signals.
	for child in get_children():
		
		# We only connect nodes that are buttons (like NewGameButt).
		if child is Button:
			# Connect the left-click/activation signal.
			child.pressed.connect(_on_button_pressed)
			
		# This check is ONLY for debugging and confirms the sound node is found
		if child.name == "clickingsound" and not is_instance_valid(click_sound):
			print("--- FATAL ERROR: Sound node was not found! ---") 


func _on_button_pressed():
	# This runs when the left mouse button is pressed on the button.
	# It stops and restarts the stream for reliable playback.
	click_sound.stop()
	click_sound.play()
