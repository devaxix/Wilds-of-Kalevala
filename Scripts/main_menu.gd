extends Control

const GAME_SCENE_PATH = "res://Scenes/Areas/Area1.tscn" 
const CREDITS_SCENE_PATH = "res://Scenes/Areas/Credits.tscn" 

func _on_new_game_button_pressed():
	# This calls the function in your Autoload to handle everything
	TransitionScreen.transition_to_scene("res://Scenes/Areas/character_select.tscn")

func _on_credits_button_pressed():
	TransitionScreen.transition_to_scene(CREDITS_SCENE_PATH)

func _on_load_game_button_pressed():
	print("Loading Game...")
	TransitionScreen.transition_to_scene(GAME_SCENE_PATH)


func _on_close_button_pressed() -> void:
	get_tree().quit()

@onready var menu_music = $MenuMusic

func _on_music_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		menu_music.stream_paused = true
	else:
		menu_music.stream_paused = false
	
