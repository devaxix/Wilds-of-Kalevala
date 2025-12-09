extends CanvasLayer

@onready var death_screen = $DeathScreen
@onready var background = $DeathScreen/Background
@onready var death_label = $DeathScreen/Label 
@onready var restart_button = $DeathScreen/Button
@onready var death_sound = $DeathSoundPlayer

# --- GENDERED DEATH SOUNDS & VOLUMES ---
@export_group("Death Audio")
@export var sfx_death_girl : AudioStream
# Slider from -40 (Silent) to 10 (Loud). Default is 0.
@export_range(-40.0, 10.0) var vol_death_girl_db : float = 0.0

@export var sfx_death_boy : AudioStream
@export_range(-40.0, 10.0) var vol_death_boy_db : float = 0.0

func _ready():
	# 1. START IN DARKNESS
	death_screen.visible = true
	background.modulate.a = 1.0 
	death_label.modulate.a = 0.0 
	restart_button.modulate.a = 0.0
	
	restart_button.pressed.connect(_on_restart_clicked)
	
	# 2. ANIMATE THE WAKE UP
	var wake_tween = create_tween()
	wake_tween.tween_interval(0.5)
	wake_tween.tween_property(background, "modulate:a", 0.0, 1.5)
	wake_tween.tween_callback(func(): death_screen.visible = false)

func show_game_over():
	# 1. Freeze Game
	get_tree().paused = true
	
	# 2. Reset Opacity
	death_screen.visible = true
	background.modulate.a = 0
	death_label.modulate.a = 0
	restart_button.modulate.a = 0
	
	# 3. Enable Mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# --- 4. PLAY SOUND WITH CORRECT VOLUME ---
	if death_sound:
		if "Girl" in GameManager.selected_character_path:
			death_sound.stream = sfx_death_girl
			death_sound.volume_db = vol_death_girl_db # Apply Girl Volume
		else:
			death_sound.stream = sfx_death_boy
			death_sound.volume_db = vol_death_boy_db # Apply Boy Volume
			
		death_sound.play()
	
	# 5. CINEMATIC DEATH SEQUENCE
	var tween = create_tween()
	
	# Phase A: Fade Background
	tween.tween_property(background, "modulate:a", 1.0, 1.0)
	
	# Long dramatic pause (2.0s)
	tween.tween_interval(2.0) 
	
	# Phase B: Show Text & Button
	tween.set_parallel(true)
	tween.tween_property(death_label, "modulate:a", 1.0, 1.5)
	tween.tween_property(restart_button, "modulate:a", 1.0, 1.5)

func _on_restart_clicked():
	restart_button.disabled = true
	
	# Smooth Exit
	var exit_tween = create_tween()
	exit_tween.set_parallel(true)
	exit_tween.tween_property(death_label, "modulate:a", 0.0, 1.0)
	exit_tween.tween_property(restart_button, "modulate:a", 0.0, 1.0)
	
	exit_tween.chain().tween_callback(_perform_reload)

func _perform_reload():
	get_tree().paused = false
	get_tree().reload_current_scene()
	restart_button.disabled = false
