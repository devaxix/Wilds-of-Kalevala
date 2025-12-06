extends Node2D

@onready var spawn_point = $PlayerSpawnPoint
@onready var game_ui = $GameUI

# --- AMBIANCE REFERENCES (Checked conditionally for scene existence) ---
# AUTUMN
@onready var wind_ambiance = $WindAmbiance if has_node("WindAmbiance") else null
@onready var crow_ambiance = $CrowAmbiance if has_node("CrowAmbiance") else null
@onready var acorn_ambiance = $AcornAmbiance if has_node("AcornAmbiance") else null
@onready var leaves_blowing_ambiance = $LeavesBlowingAmbiance if has_node("LeavesBlowingAmbiance") else null

# SUMMER
@onready var bird_ambiance = $BirdAmbiance if has_node("BirdAmbiance") else null
@onready var timed_summer_sfx = $TimedSummerSFX if has_node("TimedSummerSFX") else null
@onready var summer_loop_ambiance_2 = $SummerLoopAmbiance2 if has_node("SummerLoopAmbiance2") else null
@onready var river_ambiance = $RiverAmbiance if has_node("RiverAmbiance") else null

# SPRING
@onready var spring_bird_ambiance = $SpringBirdAmbiance if has_node("SpringBirdAmbiance") else null
@onready var woodpecker_ambiance = $WoodpeckerAmbiance if has_node("WoodpeckerAmbiance") else null
@onready var woodpecker_sfx_timer = $WoodpeckerSFXTimer if has_node("WoodpeckerSFXTimer") else null 

# UNIVERSAL RANDOM SFX (For all scenes)
@onready var random_sfx_timer = $RandomSFXTimer if has_node("RandomSFXTimer") else null
@onready var random_sfx_1 = $RandomSFX1 if has_node("RandomSFX1") else null
@onready var random_sfx_2 = $RandomSFX2 if has_node("RandomSFX2") else null
@onready var random_sfx_3 = $RandomSFX3 if has_node("RandomSFX3") else null

func _ready():
	# 1. Start all continuous ambiance sounds that EXIST in the current scene.
	
	# AUTUMN SOUNDS
	if is_instance_valid(wind_ambiance):
		wind_ambiance.play()
		
	if is_instance_valid(crow_ambiance):
		crow_ambiance.play()
		
	if is_instance_valid(acorn_ambiance):
		acorn_ambiance.play()
		
	if is_instance_valid(leaves_blowing_ambiance):
		leaves_blowing_ambiance.play()
		
	# SUMMER SOUNDS
	if is_instance_valid(bird_ambiance):
		bird_ambiance.play() 

	if is_instance_valid(summer_loop_ambiance_2):
		summer_loop_ambiance_2.play()
	
	if is_instance_valid(river_ambiance):
		river_ambiance.play()

	# SPRING SOUNDS
	if is_instance_valid(spring_bird_ambiance):
		spring_bird_ambiance.play() 
		
	# NOTE: Timed SFX are controlled by their separate Timer node signals.
		
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
	
# ----------------------------------------------------------------------
## 🔊 TIMER CALLBACK FUNCTIONS
# ----------------------------------------------------------------------

func _on_summer_sfx_timer_timeout():
	# Triggered by SummerSFXTimer (Wait Time should be 13.0 in the Summer Scene)
	if is_instance_valid(timed_summer_sfx):
		timed_summer_sfx.play()

func _on_woodpecker_sfx_timer_timeout():
	# Triggered by WoodpeckerSFXTimer (Wait Time should be 13.0 in the Spring Scene)
	if is_instance_valid(woodpecker_ambiance):
		woodpecker_ambiance.play()

func _on_random_sfx_timer_timeout() -> void:
	# Triggered by RandomSFXTimer (Wait Time should be 7.0 in ALL three scenes)
	var available_sfx: Array[AudioStreamPlayer] = []
	
	if is_instance_valid(random_sfx_1):
		available_sfx.append(random_sfx_1)
	if is_instance_valid(random_sfx_2):
		available_sfx.append(random_sfx_2)
	if is_instance_valid(random_sfx_3):
		available_sfx.append(random_sfx_3)
		
	if available_sfx.size() > 0:
		var chosen_sfx = available_sfx.pick_random()
		chosen_sfx.play()

# ----------------------------------------------------------------------
## 🚶 PLAYER SPAWN LOGIC
# ----------------------------------------------------------------------

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
