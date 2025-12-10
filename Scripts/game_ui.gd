extends CanvasLayer

# --- NODES ---
@onready var death_screen = $DeathScreen
@onready var background = $DeathScreen/Background
@onready var death_label = $DeathScreen/Label 
@onready var restart_button = $DeathScreen/Button

# AUDIO NODES
@onready var death_sound = $DeathSoundPlayer
@onready var game_over_music = $GameOverMusic

# --- AUDIO SETTINGS ---
@export_group("Death Audio")
@export var sfx_death_girl : AudioStream
@export_range(-40.0, 10.0) var vol_death_girl_db : float = 0.0

@export var sfx_death_boy : AudioStream
@export_range(-40.0, 10.0) var vol_death_boy_db : float = 0.0

@export var sfx_game_over : AudioStream 
@export_range(-40.0, 10.0) var vol_game_over_db : float = 0.0

func _ready():
	# --- 1. SAFETY LOCK (The Fix) ---
	# We force the button to be unclickable immediately.
	restart_button.disabled = true 
	restart_button.mouse_filter = Control.MOUSE_FILTER_IGNORE # Double safety!
	
	# --- 2. HANDLE LEVEL START ---
	death_screen.visible = true 
	background.modulate.a = 1.0 
	
	# Hide text/button visually
	death_label.modulate.a = 0.0 
	restart_button.modulate.a = 0.0 
	
	restart_button.pressed.connect(_on_restart_clicked)
	
	# Fade out the black screen
	var wake_tween = create_tween()
	wake_tween.tween_interval(0.5)
	wake_tween.tween_property(background, "modulate:a", 0.0, 1.5)
	
	# Turn off the screen layer when done
	wake_tween.tween_callback(func(): death_screen.visible = false)

func show_game_over():
	# 1. Freeze Game
	get_tree().paused = true
	
	# 2. TURN IT ON
	death_screen.visible = true
	
	# --- 3. UNLOCK THE BUTTON (The Fix) ---
	# Only NOW do we allow clicking!
	restart_button.disabled = false
	restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Reset Opacity
	background.modulate.a = 0
	death_label.modulate.a = 0
	restart_button.modulate.a = 0
	
	# 4. Enable Mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# 5. Play Sounds
	if death_sound:
		if "Girl" in GameManager.selected_character_path:
			death_sound.stream = sfx_death_girl
			death_sound.volume_db = vol_death_girl_db
		else:
			death_sound.stream = sfx_death_boy
			death_sound.volume_db = vol_death_boy_db
		death_sound.play()
		
	if game_over_music and sfx_game_over:
		game_over_music.stream = sfx_game_over
		game_over_music.volume_db = vol_game_over_db
		game_over_music.play()
	
	# 6. Animation
	var tween = create_tween()
	
	# Fade Background
	tween.tween_property(background, "modulate:a", 1.0, 1.0)
	tween.tween_interval(2.0) 
	
	# Fade Text & Button
	tween.set_parallel(true)
	tween.tween_property(death_label, "modulate:a", 1.0, 1.5)
	tween.tween_property(restart_button, "modulate:a", 1.0, 1.5)

func _on_restart_clicked():
	# Re-lock the button instantly so you can't click it twice
	restart_button.disabled = true
	
	var exit_tween = create_tween()
	exit_tween.set_parallel(true)
	exit_tween.tween_property(death_label, "modulate:a", 0.0, 1.0)
	exit_tween.tween_property(restart_button, "modulate:a", 0.0, 1.0)
	
	exit_tween.chain().tween_callback(_perform_reload)

func _perform_reload():
	get_tree().paused = false
	get_tree().reload_current_scene()
	# Button stays disabled until _ready() runs again in the new scene
