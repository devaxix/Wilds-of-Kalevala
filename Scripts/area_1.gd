extends Node2D

# --- CAMERA LIMITS ---
@export var camera_limit_right: int = 10000 
@export var camera_limit_bottom: int = 1080 
@export var camera_limit_top: int = 0
@export var camera_limit_left: int = -830

@export_enum("Spring", "Summer", "Autumn", "Winter") var level_season: String = "Spring"

@onready var spawn_point = $PlayerSpawnPoint
@onready var game_ui = $GameUI

# We need this variable so other functions (like the dialogue) can find the player
var player_instance : CharacterBody2D 

# --- HEALTH UI REFERENCES ---
@onready var heart1 = $GameUI/HeartContainer/Heart1 if has_node("GameUI/HeartContainer/Heart1") else null
@onready var heart2 = $GameUI/HeartContainer/Heart2 if has_node("GameUI/HeartContainer/Heart2") else null
@onready var heart3 = $GameUI/HeartContainer/Heart3 if has_node("GameUI/HeartContainer/Heart3") else null

const FULL_HEART: Texture2D = preload("res://Sprites/heart.png")
const EMPTY_HEART: Texture2D = preload("res://Sprites/empty heart 1.png")

# --- AMBIANCE REFERENCES (All your existing vars) ---
@onready var wind_ambiance = $WindAmbiance if has_node("WindAmbiance") else null
@onready var crow_ambiance = $CrowAmbiance if has_node("CrowAmbiance") else null
@onready var acorn_ambiance = $AcornAmbiance if has_node("AcornAmbiance") else null
@onready var leaves_blowing_ambiance = $LeavesBlowingAmbiance if has_node("LeavesBlowingAmbiance") else null
@onready var bird_ambiance = $BirdAmbiance if has_node("BirdAmbiance") else null
@onready var timed_summer_sfx = $TimedSummerSFX if has_node("TimedSummerSFX") else null
@onready var summer_loop_ambiance_2 = $SummerLoopAmbiance2 if has_node("SummerLoopAmbiance2") else null
@onready var river_ambiance = $RiverAmbiance if has_node("RiverAmbiance") else null
@onready var spring_bird_ambiance = $SpringBirdAmbiance if has_node("SpringBirdAmbiance") else null
@onready var woodpecker_ambiance = $WoodpeckerAmbiance if has_node("WoodpeckerAmbiance") else null
@onready var woodpecker_sfx_timer = $WoodpeckerSFXTimer if has_node("WoodpeckerSFXTimer") else null
@onready var random_sfx_timer = $RandomSFXTimer if has_node("RandomSFXTimer") else null
@onready var random_sfx_1 = $RandomSFX1 if has_node("RandomSFX1") else null
@onready var random_sfx_2 = $RandomSFX2 if has_node("RandomSFX2") else null
@onready var random_sfx_3 = $RandomSFX3 if has_node("RandomSFX3") else null

func _ready():
	# 1. Update Manager
	if is_instance_valid(GameManager):
		GameManager.current_season = level_season
		print("Level Loaded. Season updated to: ", level_season)

	# 2. Start Ambiance (Keep existing)
	if is_instance_valid(wind_ambiance): wind_ambiance.play()
	if is_instance_valid(crow_ambiance): crow_ambiance.play()
	if is_instance_valid(acorn_ambiance): acorn_ambiance.play()
	if is_instance_valid(leaves_blowing_ambiance): leaves_blowing_ambiance.play()
	if is_instance_valid(bird_ambiance): bird_ambiance.play()
	if is_instance_valid(summer_loop_ambiance_2): summer_loop_ambiance_2.play()
	if is_instance_valid(river_ambiance): river_ambiance.play()
	if is_instance_valid(spring_bird_ambiance): spring_bird_ambiance.play()
	
	# 3. Reset Hearts & Spawn
	update_hearts_ui(3)
	spawn_player()
	
	# 4. START INTRO DIALOGUE (Only if Spring AND Not Seen Yet!)
	if level_season == "Spring":
		if GameManager.has_seen_spring_intro == false:
			start_spring_intro()
			GameManager.has_seen_spring_intro = true # Mark as seen!
		else:
			print("Skipping Spring Intro (Already seen)")
	else:
		pass
# --- NEW: THE NARRATOR SEQUENCE ---
func start_spring_intro():
	# 1. Lock Player
	# We wait a frame to ensure the player is fully added to the scene tree
	await get_tree().process_frame
	
	if is_instance_valid(player_instance):
		player_instance.set_physics_process(false)
		player_instance.velocity = Vector2.ZERO
		if player_instance.has_node("AnimationPlayer"):
			player_instance.get_node("AnimationPlayer").play("Idle")

	# 2. NARRATOR TEXT
	var narrator_text: Array[String] = [
		"You open your eyes to the sound of rain. The forest is soft and alive...",
		"The air smells like growing moist plants. Flowers are starting to bloom.. Tiny fireflies drift between trees.",
		"Something warm had been beside you, a presence, a light..",
		"But when you reached for it… it vanished.",
		"Only the echo of its warmth lingers, like a heartbeat under your skin.",
		"You see faint pawprints through the mud and puddles.",
		"Each step you take is accompanied by echoes of laughter, voices you can't quite place or remember.",
		"Fragments of your memories smell like rain: a name, a promise, warmth but.. they are scattered."
	]
	
	# Play Narrator lines above player
	DialogueManager.start_dialogue(player_instance.global_position, narrator_text)
	await DialogueManager.dialogue_finished
	
	# 3. THE PAUSE (Box closes... wait... open again)
	await get_tree().create_timer(0.5).timeout
	
	# 4. PLAYER TEXT
	var player_text: Array[String] = ["I need to find them."]
	DialogueManager.start_dialogue(player_instance.global_position, player_text)
	await DialogueManager.dialogue_finished
	
	# 5. UNLOCK PLAYER
	if is_instance_valid(player_instance):
		player_instance.set_physics_process(true)

# --- TIMERS ---
func _on_summer_sfx_timer_timeout():
	if is_instance_valid(timed_summer_sfx): timed_summer_sfx.play()

func _on_woodpecker_sfx_timer_timeout():
	if is_instance_valid(woodpecker_ambiance): woodpecker_ambiance.play()

func _on_random_sfx_timer_timeout() -> void:
	var available_sfx: Array[AudioStreamPlayer] = []
	if is_instance_valid(random_sfx_1): available_sfx.append(random_sfx_1)
	if is_instance_valid(random_sfx_2): available_sfx.append(random_sfx_2)
	if is_instance_valid(random_sfx_3): available_sfx.append(random_sfx_3)
	
	if available_sfx.size() > 0:
		available_sfx.pick_random().play()

# --- UI UPDATE ---
func update_hearts_ui(current_health: int):
	if is_instance_valid(heart3):
		heart3.texture = FULL_HEART if current_health >= 3 else EMPTY_HEART
	if is_instance_valid(heart2):
		heart2.texture = FULL_HEART if current_health >= 2 else EMPTY_HEART
	if is_instance_valid(heart1):
		heart1.texture = FULL_HEART if current_health >= 1 else EMPTY_HEART

# --- SPAWN PLAYER ---
func spawn_player():
	var player_scene = load(GameManager.selected_character_path)
	
	# We assign to the class variable 'player_instance' instead of a local var
	player_instance = player_scene.instantiate()
	
	# Connect Signals
	if player_instance.has_signal("health_changed"):
		player_instance.health_changed.connect(update_hearts_ui)
	
	if player_instance.has_signal("player_died"):
		player_instance.player_died.connect(game_ui.show_game_over)
	
	player_instance.position = spawn_point.position
	player_instance.name = "Player"
	player_instance.game_ui = game_ui
	add_child(player_instance)
