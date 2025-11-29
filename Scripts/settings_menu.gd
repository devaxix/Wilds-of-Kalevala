extends Control

signal closed

# Make sure these paths match your Scene Tree!
@onready var fullscreen_toggle = $HBoxContainer/FullscreenButton
@onready var volume_slider = $"Volume Slider"

var screen_height = 0

func _ready():
	screen_height = get_viewport_rect().size.y
	position.y = screen_height
	visible = false
	
	# --- 1. SYNC FULLSCREEN (Handles "On by Default") ---
	# We check the actual window mode. If Project Settings -> Display -> Window -> Mode
	# is set to "Fullscreen", this will return true, and the button will auto-check itself.
	var current_mode = DisplayServer.window_get_mode()
	var is_fullscreen = (current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN or current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	fullscreen_toggle.set_pressed_no_signal(is_fullscreen)
	
	# --- 2. SYNC VOLUME (Handles "Start on Max") ---
	# We check the actual AudioServer volume.
	# By default, Godot buses start at 0dB (Max).
	# db_to_linear(0) = 1.0. So this will set the slider to the far right (Max).
	var bus_index = AudioServer.get_bus_index("Master")
	var current_db = AudioServer.get_bus_volume_db(bus_index)
	volume_slider.value = db_to_linear(current_db)

# --- ANIMATION LOGIC (Your values preserved!) ---
func open():
	visible = true
	var tween = create_tween()
	# Kept TRANS_BACK and 0.5s duration
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", 0.0, 0.5)

func close():
	var tween = create_tween()
	# Kept TRANS_BACK and 0.5s duration
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position:y", screen_height, 0.5)
	
	await tween.finished
	visible = false
	closed.emit()

func _on_back_button_pressed():
	close()

# --- SETTING FUNCTIONS ---

func _on_fullscreen_toggle_toggled(toggled_on):
	if toggled_on:
		# Go to Exclusive Fullscreen (Best performance)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		# 1. Force Windowed Mode FIRST
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		# 2. Resize the Window
		get_window().size = Vector2(1280, 720)
		
		# 3. Center it
		get_window().move_to_center()

func _on_volume_slider_value_changed(value):
	# Convert 0-1 slider value to Decibels
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
