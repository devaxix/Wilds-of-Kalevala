extends Control

const GAME_SCENE_PATH = "res://Scenes/Areas/Area1.tscn" 
const CREDITS_SCENE_PATH = "res://Scenes/Areas/Credits.tscn" 

func _on_new_game_button_pressed():
	# This calls the function in your Autoload to handle everything
	TransitionScreen.transition_to_scene("res://Scenes/Areas/intro_cutscene.tscn")

func _on_credits_button_pressed():
	TransitionScreen.transition_to_scene(CREDITS_SCENE_PATH)

func _on_load_game_button_pressed():
	print("Loading Game...")
	TransitionScreen.transition_to_scene(GAME_SCENE_PATH)


func _on_close_button_pressed() -> void:
	get_tree().quit()

@onready var menu_music = $MenuMusic

func _on_music_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		menu_music.stream_paused = true
	else:
		menu_music.stream_paused = false
	
@onready var background_click_sound = $BackgroundClickSound

func _unhandled_input(event):
	# Check for Left Mouse Click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Play sound with random pitch
		background_click_sound.pitch_scale = randf_range(0.9, 1.1)
		background_click_sound.play()

@onready var menu_fox = $"Layers for background/Fox/Sprite2D/MenuFox"

@onready var settings_menu = $SettingsMenu

func _on_settings_button_pressed():
	# 1. Fade OUT the main menu UI
	fade_ui(0.0) 
	
	# 2. Open the Settings panel
	settings_menu.open()
	
@onready var logo_container = $"layers for logo"
@onready var buttons_container = $Buttons

func _ready():
	# 1. Setup Initial State (Invisible)
	logo_container.modulate.a = 0.0
	buttons_container.modulate.a = 0.0
	
	# 2. Start the Fade In
	start_intro_fade()
	
	# 1. Connect the "closed" signal from SettingsMenu
	if not settings_menu.closed.is_connected(_on_settings_closed):
		settings_menu.closed.connect(_on_settings_closed)
	
	# ... (start_intro_fade call) ...

# 2. Create the function that runs when Settings close
func _on_settings_closed():
	# Fade IN the main menu UI
	fade_ui(1.0)

func start_intro_fade():
	var tween = create_tween()
	
	# A. Fade in the LOGO first (takes 1.5 seconds)
	tween.tween_property(logo_container, "modulate:a", 1.0, 3.5).set_ease(Tween.EASE_OUT)
	
	# B. Wait a tiny bit (0.5s) so the logo appears first
	tween.tween_interval(0.0)
	
	# C. Fade in the BUTTONS (takes 1.0 second)
	# set_parallel(true) runs this AT THE SAME TIME as the next command if you had one
	tween.tween_property(buttons_container, "modulate:a", 1.0, 1.0).set_ease(Tween.EASE_OUT)

# target_alpha: 0.0 (Invisible) or 1.0 (Visible)
func fade_ui(target_alpha):
	var tween = create_tween()
	# Animate both containers at the same time
	tween.set_parallel(true)
	tween.tween_property(logo_container, "modulate:a", target_alpha, 0.2)
	tween.tween_property(buttons_container, "modulate:a", target_alpha, 0.2)
