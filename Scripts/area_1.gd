extends Node2D

@onready var spawn_point = $PlayerSpawnPoint
@onready var game_ui = $GameUI # Make sure your UI is in the scene!

func _ready():
	spawn_player()
	# ... your spawning logic ...
	
	# Wait a split second so the player sees the level load
	await get_tree().create_timer(0.7).timeout
	
	# Define your lines!
	var lines: Array[String] = [
		"Ah... my head...",
		"I hit it pretty hard...",
		"Wait...",
		"What was my name again?"
	]
	
	# Start the dialogue above the Spawn Point
	# (You can use the player's position if you have a reference to them)
	DialogueManager.start_dialogue($PlayerSpawnPoint.global_position, lines)
	
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
