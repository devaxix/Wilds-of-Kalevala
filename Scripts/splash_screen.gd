extends Control

# --- SETTINGS ---
@export var logo_variations: Array[Texture2D] 
@export_file("*.tscn") var main_menu_path: String = "res://Scenes/Areas/main_menu.tscn"

# --- TIMING ---
@export var logo_fade_in_time: float = 1.5
@export var logo_hold_time: float = 3.5    # <-- Increase this to keep logo on screen longer!
@export var logo_fade_out_time: float = 1.5

@onready var logo_display = $LogoDisplay

func _ready():
	if logo_variations.size() > 0:
		logo_display.texture = logo_variations.pick_random()
	
	# Start black (Logo invisible)
	logo_display.modulate.a = 0.0
	
	start_splash_sequence()

func start_splash_sequence():
	var tween = create_tween()
	
	# 1. Fade Logo IN (Black -> Image)
	tween.tween_property(logo_display, "modulate:a", 1.0, logo_fade_in_time)
	
	# 2. WAIT (This is where you control how long the player stares at the logo)
	tween.tween_interval(logo_hold_time)
	
	# 3. Fade Logo OUT (Image -> Black)
	tween.tween_property(logo_display, "modulate:a", 0.0, logo_fade_out_time)
	
	# 4. START SCENE TRANSITION
	tween.tween_callback(go_to_main_menu)

func go_to_main_menu():
	# Use your new transition with a specific speed
	# 2.0 seconds is a nice standard speed for the menu load
	if has_node("/root/TransitionScreen"):
		TransitionScreen.transition_to_scene(main_menu_path, 3.0)
	else:
		get_tree().change_scene_to_file(main_menu_path)
