extends Control

# Verify these paths match your actual files!
const BOY_SCENE_PATH = "res://Scenes/Player/player.tscn"
const GIRL_SCENE_PATH = "res://Scenes/Player/Player_Girl.tscn"
const LEVEL_1_PATH = "res://Scenes/Areas/Area1.tscn"

func _ready():
	# Optional: Connect signals via code if you prefer, 
	# OR connect them in the editor (Node tab -> pressed)
	pass

# Connect the BoyButton "pressed" signal here
func _on_boy_button_pressed():
	print("You chose the Boy!")
	GameManager.selected_character_path = BOY_SCENE_PATH
	start_game()

# Connect the GirlButton "pressed" signal here
func _on_girl_button_pressed():
	print("You chose the Girl!")
	GameManager.selected_character_path = GIRL_SCENE_PATH
	start_game()

func start_game():
	# Transition to the actual level
	TransitionScreen.transition_to_scene(LEVEL_1_PATH)
