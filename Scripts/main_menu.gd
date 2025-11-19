extends Control

const GAME_SCENE_PATH = "res://Scenes/Areas/Area1.tscn" 
const CREDITS_SCENE_PATH = "res://Scenes/Credits.tscn" 

func _on_new_game_button_pressed():
	print("Starting New Game...")
	# Use get_tree().change_scene_to_file() for scene switching
	var error = get_tree().change_scene_to_file(GAME_SCENE_PATH)
	if error != OK:
		print("ERROR: Failed to load scene: ", GAME_SCENE_PATH, " Error Code: ", error)

# --- Load Game Logic ---
func _on_load_game_button_pressed():
	print("Loading Game...")
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

# --- Settings Logic ---
func _on_settings_button_pressed():
	print("Opening Settings panel...")
	# Implement logic here

# --- Credits Logic ---
func _on_credits_button_pressed():
	print("Opening Credits...")
	get_tree().change_scene_to_file(CREDITS_SCENE_PATH)
