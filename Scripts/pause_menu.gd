extends CanvasLayer

# Use % to find nodes even if they are moved inside containers
@onready var settings_menu = $SettingsMenu 
@onready var panel_container = %TextureRect # Make sure you right-click the Board and "Access as Unique Name"

# --- BUTTONS (Using Unique Names is safer!) ---
@onready var resume_btn = %ResumeButton
@onready var settings_btn = %SettingsButton
@onready var main_menu_btn = %MainMenuButton

var screen_height = 0
var center_pos_y = 0

func _ready():
	visible = false
	
	# Calculate positions for animation
	screen_height = get_viewport().get_visible_rect().size.y
	center_pos_y = panel_container.position.y 
	
	# Connect Buttons
	# We check if they exist first to prevent crashes
	if resume_btn: resume_btn.pressed.connect(_on_resume_pressed)
	if settings_btn: settings_btn.pressed.connect(_on_settings_pressed)
	if main_menu_btn: main_menu_btn.pressed.connect(_on_mainmenu_pressed)
	
		# ... existing code ...
	if resume_btn:
		print("Resume Button Found!")
	else:
		print("ERROR: Resume Button NOT found. Check the name!")

func _input(event):
	# "ui_cancel" is the ESC key by default
	if event.is_action_pressed("ui_cancel"): 
		toggle_pause()

func toggle_pause():
	# If settings is open, close it first
	if settings_menu and settings_menu.visible:
		settings_menu.close()
		return

	var is_game_paused = get_tree().paused
	
	if is_game_paused:
		close_menu() 
	else:
		open_menu()

# --- ANIMATION FUNCTIONS ---

func open_menu():
	visible = true
	get_tree().paused = true
	
	# 1. Move Board off-screen (Top)
	panel_container.position.y = -screen_height
	
	# 2. Slide DOWN to center
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# REMOVED the ".set_update_mode" error here
	tween.tween_property(panel_container, "position:y", center_pos_y, 0.5)

func close_menu():
	# 1. Slide UP off-screen
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(panel_container, "position:y", -screen_height, 0.5)
	
	# 2. Wait for animation to finish
	await tween.finished
	
	# 3. Hide and Unpause
	visible = false
	get_tree().paused = false

# --- BUTTONS ---

func _on_resume_pressed():
	close_menu() 

func _on_settings_pressed():
	if settings_menu:
		settings_menu.open()

func _on_mainmenu_pressed():
	get_tree().paused = false 
	# Make sure TransitionScreen is an Autoload, or this line will error!
	TransitionScreen.transition_to_scene("res://Scenes/Areas/main_menu.tscn")
