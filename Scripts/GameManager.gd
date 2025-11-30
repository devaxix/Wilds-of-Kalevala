extends Node

var selected_character_path : String = "res://Scenes/Player/Player_Girl.tscn" 

var player_name : String = "Hero"

# --- PERMANENT MEMORY STORAGE ---
# These variables live here, so they survive scene changes!
var unlocked_sword = false
var unlocked_wall_jump = false
var unlocked_double_jump = false
var unlocked_dash = false
