extends TextureButton

# Store the original location so we don't drift away
var original_y = 0

func _ready():
	# Remember where we placed it in the editor
	original_y = position.y
	
	# Connect the built-in signals
	button_down.connect(_on_button_pressed)
	button_up.connect(_on_button_released)

func _on_button_pressed():
	# Move down 2 pixels
	position.y = original_y + 4

func _on_button_released():
	# Snap back to original position
	position.y = original_y
