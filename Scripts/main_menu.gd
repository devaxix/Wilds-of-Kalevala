extends Control

# NOTE: Scene and config file paths
const GAME_SCENE_PATH = "res://Scenes/Areas/Area1.tscn"
const CREDITS_SCENE_PATH = "res://Scenes/Areas/Credits.tscn"
const CONFIG_FILE_PATH = "user://game_settings.cfg" # File path for saving settings

# --- Audio Bus Variables (Used to control volume) ---
var music_bus_idx = 0
var sfx_bus_idx = 0

# --- Node References (Must match your Scene Tree structure) ---
@onready var menu_music = $MenuMusic
@onready var animation_player = $SettingScreen/AnimationPlayer
@onready var settings_screen = $SettingScreen 
@onready var main_menu_content = $MainMenuContent
@onready var hover_sound_player = $HoverSoundPlayer
@onready var click_sound_player = $ClickSoundPlayer 

# --- SLIDER NODE REFERENCES (Must match the HSlider and TextureRect names) ---
# NOTE: Using get_node_or_null() for icons to prevent crash if node path is wrong or the node is missing.
@onready var music_slider = $SettingScreen/MusicSlider
@onready var sfx_slider = $SettingScreen/SFXSlider

# The error was here, so we'll use get_node_or_null() to prevent the crash
@onready var music_mute_icon = get_node_or_null("SettingScreen/MusicMuteIcon")
@onready var music_full_icon = get_node_or_null("SettingScreen/MusicFullIcon")
@onready var sfx_mute_icon = get_node_or_null("SettingScreen/SFXMuteIcon")
@onready var sfx_full_icon = get_node_or_null("SettingScreen/SFXFullIcon")
# ----------------------------

func _ready():
	# 1. Find the indices of the audio buses (requires buses named "Music" and "SFX" in Audio Bus Layout)
	music_bus_idx = AudioServer.get_bus_index("Music")
	sfx_bus_idx = AudioServer.get_bus_index("SFX")
	
	# 2. Load saved settings and apply volume
	load_settings()
	
	# 3. Initialize icon states based on the loaded volume (now uses instance checks)
	if is_instance_valid(music_slider):
		update_music_icons(music_slider.value)
	if is_instance_valid(sfx_slider):
		update_sfx_icons(sfx_slider.value)

# --- Icon Logic Functions ---

func update_music_icons(value: float):
	# Check if the sliders and icons are valid before trying to access them
	if is_instance_valid(music_slider) and is_instance_valid(music_mute_icon) and is_instance_valid(music_full_icon):
		# Mute icon visible if volume is near minimum (e.g., within 0.5 dB of -40 dB)
		music_mute_icon.visible = value <= music_slider.min_value + 0.5 
		# Full icon visible if volume is near maximum
		music_full_icon.visible = value >= music_slider.max_value - 0.5

func update_sfx_icons(value: float):
	# Check if the sliders and icons are valid before trying to access them
	if is_instance_valid(sfx_slider) and is_instance_valid(sfx_mute_icon) and is_instance_valid(sfx_full_icon):
		# Mute icon visible if volume is near minimum
		sfx_mute_icon.visible = value <= sfx_slider.min_value + 0.5
		# Full icon visible if volume is near maximum
		sfx_full_icon.visible = value >= sfx_slider.max_value - 0.5

# --- Settings Persistence (Saving/Loading) ---

func save_settings():
	var config = ConfigFile.new()
	if is_instance_valid(music_slider):
		config.set_value("Audio", "music_volume", music_slider.value)
	if is_instance_valid(sfx_slider):
		config.set_value("Audio", "sfx_volume", sfx_slider.value)
		
	var error = config.save(CONFIG_FILE_PATH)
	if error != OK:
		print("Error saving settings: ", error)

func load_settings():
	var config = ConfigFile.new()
	var error = config.load(CONFIG_FILE_PATH)
	var default_volume = 0.0 # Default volume is 0 dB (full volume)
	
	if error != OK:
		print("No settings file found. Using defaults.")
	
	# Load Music Volume
	if music_bus_idx != -1 and is_instance_valid(music_slider):
		var music_vol = config.get_value("Audio", "music_volume", default_volume)
		music_slider.value = music_vol
		AudioServer.set_bus_volume_db(music_bus_idx, music_vol)
	
	# Load SFX Volume
	if sfx_bus_idx != -1 and is_instance_valid(sfx_slider):
		var sfx_vol = config.get_value("Audio", "sfx_volume", default_volume)
		sfx_slider.value = sfx_vol
		AudioServer.set_bus_volume_db(sfx_bus_idx, sfx_vol)

# --- SLIDER CONTROL FUNCTIONS (These MUST be connected to the HSlider signals) ---

func _on_music_slider_value_changed(value: float) -> void:
	if music_bus_idx != -1:
		# Set the volume of the Music bus to the slider value (in dB)
		AudioServer.set_bus_volume_db(music_bus_idx, value)
		update_music_icons(value)
		save_settings() # Save immediately

func _on_sfx_slider_value_changed(value: float) -> void:
	if sfx_bus_idx != -1:
		# Set the volume of the SFX bus to the slider value (in dB)
		AudioServer.set_bus_volume_db(sfx_bus_idx, value)
		update_sfx_icons(value)
		save_settings() # Save immediately

# --- Core Menu Functionality (Saving settings on exit) ---

func _on_new_game_butt_pressed():
	save_settings()
	queue_free()
	TransitionScreen.transition_to_scene(GAME_SCENE_PATH)

func _on_credits_butt_pressed():
	save_settings()
	queue_free()
	TransitionScreen.transition_to_scene(CREDITS_SCENE_PATH)

func _on_load_game_butt_pressed():
	save_settings()
	print("Loading Game...")
	queue_free()
	TransitionScreen.transition_to_scene(GAME_SCENE_PATH)

func _on_close_button_pressed() -> void:
	save_settings()
	get_tree().quit()

# --- Settings Animation (Slide In) ---

func _on_settings_butt_pressed():
	if is_instance_valid(settings_screen) and is_instance_valid(animation_player):
		settings_screen.visible = true
		
		# 2. Play the animation 
		animation_player.play("SlideInSettings")
		
		# 3. Disable input on the main content while animation plays
		main_menu_content.mouse_filter = MOUSE_FILTER_IGNORE
		
		# 4. Wait for the animation to complete.
		await animation_player.animation_finished
		
		# 5. Restore interaction 
		main_menu_content.mouse_filter = MOUSE_FILTER_PASS
	else:
		# Fallback if settings screen nodes are missing
		print("ERROR: SettingsScreen or AnimationPlayer node not found.")

# --- Toggles and Input ---

func _on_music_toggle_toggled(toggled_on: bool) -> void:
	# toggled_on is true when the button is pressed down/off
	if is_instance_valid(menu_music):
		menu_music.stream_paused = toggled_on

func _on_button_hovered():
	if is_instance_valid(hover_sound_player):
		hover_sound_player.play()

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_instance_valid(click_sound_player):
			click_sound_player.play()
			
