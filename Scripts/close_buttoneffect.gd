extends TextureButton

# Store the original location so we don't drift away
var original_y = 0

# FINAL PATH FIX: We use get_parent() to go up to the 'Buttons' container,
# and then get_node() to find the direct child 'clickingsound' inside of it.
@onready var click_sound = get_parent().get_node("clickingsound")

func _ready():
	# Remember where we placed it in the editor
	original_y = position.y
	
	# Connect the built-in signals
	button_down.connect(_on_button_pressed)
	button_up.connect(_on_button_released)

func _on_button_pressed():
	# Move down 4 pixels
	position.y = original_y + 4

func _on_button_released():
	# Snap back to original position
	position.y = original_y
	
	# Play the sound when the button is released!
	if is_instance_valid(click_sound):
		click_sound.stop()
		click_sound.play()
