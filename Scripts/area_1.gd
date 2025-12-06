extends Node2D

@onready var spawn_point = $PlayerSpawnPoint
@onready var game_ui = $GameUI
@onready var wind_ambiance = $WindAmbiance
@onready var crow_ambiance = $CrowAmbiance
@onready var acorn_ambiance = $AcornAmbiance
@onready var leaves_blowing_ambiance = $LeavesBlowingAmbiance # New reference for leaves sound!

func _ready():
	# 1. Start all continuous ambiance sounds
	if is_instance_valid(wind_ambiance):
		wind_ambiance.play()
		
	if is_instance_valid(crow_ambiance):
		crow_ambiance.play()
		
	if is_instance_valid(acorn_ambiance):
		acorn_ambiance.play()
		
	if is_instance_valid(leaves_blowing_ambiance): # Start the new leaves sound loop
		leaves_blowing_ambiance.play()
		
	# 2. Spawn the Player
	spawn_player()
	
	# Wait a split second so the player sees the level load
	await get_tree().create_timer(0.7).timeout
	
	# Define your lines!
	var lines: Array[String] = [
		
		"What was my name again?"
	]
	
	# Start the dialogue above the Spawn Point
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
	
	# 5. Connect the UI manually
	player_instance.game_ui = game_ui
	
	# 6. Add it to the world
	add_child(player_instance)
