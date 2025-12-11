extends Control

# --- CONFIGURATION ---
const MAIN_MENU_PATH = "res://Scenes/Areas/main_menu.tscn"
@export var scroll_speed: float = 60.0 

# NEW: How far below the screen does it start? 
# Increase this number to wait longer before text appears.
@export var start_padding: float = 500.0 

# --- NODES ---
@onready var credits_label = $CreditsLabel
@onready var back_button = $BackButton

func _ready():
	# SAFETY CHECK
	if credits_label == null:
		print("ERROR: Node 'CreditsLabel' missing.")
		set_process(false)
		return

	# 1. SETUP CREDITS TEXT
	credits_label.text = """
	WILDS OF KALEVALA
A Game by Studio Pantheon



--- PROGRAMMING & ENGINEERING ---

Devin ................. Lead Programmer
Elle .................. Gameplay, Systems & Audio


--- ART & VISUALS ---

Elle .................. Visual Arts Director & Sound Designing
Daniel ................ World Art & Tilesets
Clark ................. Character Artist
Andrew ................ Concept Artist


--- AUDIO & SOUNDTRACK ---

Katarai ............... Lead Composer
Elle .................. Composer & Sound Design


--- PRODUCTION & SUPPORT ---

Daniel ................ Organization & Planning


--- SPECIAL THANKS ---

To our friends and family who supported us.
And to you, for playing.


© 2025 Studio Pantheon
	"""
	
	# 2. ALIGNMENT
	credits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# 3. START POSITION (The Fix)
	# We take the screen height (1080) and ADD the padding.
	credits_label.position.y = 1080 + start_padding
	
	# 4. BUTTON CONNECTION
	if back_button:
		if back_button.pressed.is_connected(_return_to_menu):
			back_button.pressed.disconnect(_return_to_menu)
		back_button.pressed.connect(_return_to_menu)

func _process(delta):
	if credits_label:
		credits_label.position.y -= scroll_speed * delta
		
		# Return when text goes off top
		if credits_label.position.y + credits_label.size.y < -50:
			_return_to_menu()

func _return_to_menu():
	# Use the Transition Manager if it exists!
	if has_node("/root/TransitionScreen"):
		TransitionScreen.transition_to_scene(MAIN_MENU_PATH)
	else:
		get_tree().change_scene_to_file(MAIN_MENU_PATH)
