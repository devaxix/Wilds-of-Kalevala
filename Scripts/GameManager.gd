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
	
# --- DIALOGUE MEMORY ---
var has_seen_spring_intro = false # New variable!
var has_seen_summer_intro: bool = false
var has_triggered_summer_fox_event: bool = false # To stop the "What was that?" repeat
var has_seen_autumn_intro: bool = false
var has_seen_autumn_cutscene: bool = false
