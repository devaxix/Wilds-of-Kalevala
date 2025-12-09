extends Node

var selected_character_path : String = "res://Scenes/Player/Player_Girl.tscn" 

var player_name : String = "Hero"

# --- PERMANENT MEMORY STORAGE ---
var unlocked_sword = false
var unlocked_wall_jump = false
var unlocked_double_jump = false
var unlocked_dash = false

var current_season = "Spring" # Default

func _ready():
	# --- FIX: RUNTIME ONLY BLACK BACKGROUND ---
	# This turns the "empty space" black when the game plays (preventing white flashes),
	# but leaves your Editor background gray!
	RenderingServer.set_default_clear_color(Color.BLACK)
