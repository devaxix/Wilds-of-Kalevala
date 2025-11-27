extends Node2D

@onready var spawn_point = $PlayerSpawnPoint
@onready var game_ui = $GameUI # Make sure your UI is in the scene!

func _ready():
	spawn_player()

func spawn_player():
	# 1. Load the scene file we chose in the menu
	var player_scene = load(GameManager.selected_character_path)
	
	# 2. Create an instance of it
	var player_instance = player_scene.instantiate()
	
	# 3. Position it at the spawn point
	player_instance.position = spawn_point.position
	
	# 4. CRITICAL: Name it "Player" so the Skeleton can find it!
	player_instance.name = "Player"
	
	# 5. Connect the UI manually (since we can't drag-and-drop in inspector anymore)
	player_instance.game_ui = game_ui
	
	# 6. Add it to the world
	add_child(player_instance)
