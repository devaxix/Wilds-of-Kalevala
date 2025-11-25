extends AudioStreamPlayer

# This special function checks every input event (key press, mouse click, etc.)
func _input(event):
	
	# Check if the input was a mouse button being pressed down
	if event is InputEventMouseButton and event.pressed:
		
		# Check if that mouse button was the LEFT mouse button
		if event.button_index == MOUSE_BUTTON_LEFT:
			
			# Since this script is attached to the AudioStreamPlayer itself,
			# we can just call play() directly.
			play()
