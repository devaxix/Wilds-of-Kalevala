extends Node

var selected_character_path : String = "res://Scenes/Player/Player_Girl.tscn"

func _on_boy_button_pressed():
	# Store the path to the Boy scene
	GameManager.selected_character_path = "res://Scenes/Player/player.tscn"
	print("Selected: Boy")
	# (Optional: Add a border or effect to show selection)

func _on_girl_button_pressed():
	# Store the path to the Girl scene
	GameManager.selected_character_path = "res://Scenes/Player/Player_Girl.tscn"
	print("Selected: Girl")

func _on_start_game_pressed():
	# Load the level as normal
	TransitionScreen.transition_to_scene("res://Scenes/Areas/Area1.tscn")

var player_name : String = "Hero"
