extends Node2D

# --- CAMERA LIMITS ---
@export var camera_limit_right: int = 10000 
@export var camera_limit_bottom: int = 1080 
@export var camera_limit_top: int = 0
@export var camera_limit_left: int = -830

# Hardcoded for this script
var level_season: String = "Summer"

@onready var spawn_point = $PlayerSpawnPoint
@onready var game_ui = $GameUI
var player_instance : CharacterBody2D 

# --- AUDIO REFERENCES ---
# Ensure "FoxGrassSFX" exists in your scene!
@onready var fox_grass_sfx = $FoxGrassSFX if has_node("FoxGrassSFX") else null

# --- AMBIANCE ---
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

# --- HEALTH UI ---
@onready var heart1 = $GameUI/HeartContainer/Heart1 if has_node("GameUI/HeartContainer/Heart1") else null
@onready var heart2 = $GameUI/HeartContainer/Heart2 if has_node("GameUI/HeartContainer/Heart2") else null
@onready var heart3 = $GameUI/HeartContainer/Heart3 if has_node("GameUI/HeartContainer/Heart3") else null

const FULL_HEART: Texture2D = preload("res://Sprites/heart.png")
const EMPTY_HEART: Texture2D = preload("res://Sprites/empty heart 1.png")

func _ready():
	if is_instance_valid(GameManager):
		GameManager.current_season = level_season
		print("Level Loaded. Season updated to: ", level_season)

	# Start Ambiance
	if is_instance_valid(wind_ambiance): wind_ambiance.play()
	if is_instance_valid(crow_ambiance): crow_ambiance.play()
	if is_instance_valid(acorn_ambiance): acorn_ambiance.play()
	if is_instance_valid(leaves_blowing_ambiance): leaves_blowing_ambiance.play()
	if is_instance_valid(bird_ambiance): bird_ambiance.play()
	if is_instance_valid(summer_loop_ambiance_2): summer_loop_ambiance_2.play()
	if is_instance_valid(river_ambiance): river_ambiance.play()
	if is_instance_valid(spring_bird_ambiance): spring_bird_ambiance.play()
	
	update_hearts_ui(3)
	spawn_player()
	
	# --- CHECK: Have we seen the intro? ---
	if GameManager.has_seen_summer_intro == false:
		# Mark as seen so it doesn't repeat on death
		GameManager.has_seen_summer_intro = true
		start_summer_intro()

# --- SUMMER INTRO (Atmosphere Only) ---
func start_summer_intro():
	await get_tree().process_frame
	if is_instance_valid(player_instance):
		player_instance.set_physics_process(false)
		player_instance.velocity = Vector2.ZERO
		if player_instance.has_node("AnimationPlayer"):
			player_instance.get_node("AnimationPlayer").play("Idle")

	var summer_lines: Array[String] = [
		"The forest feels so warm and full of color now.",
		"The light is heavy and yellow, pouring down through the thick green trees above you.",
		"The air is warm and smells sweet from the flowers..",
		"Small animals like mice and squirrels move beneath the tall plants.",
		"The path has bright sun and shade beneath your feet.",
		"Every little noise sounds bigger in this humid, hot air. Light dances between leaves like laughter.",
		"You remember what it felt like to be unafraid."
	]
	
	DialogueManager.start_dialogue(summer_lines)
	await DialogueManager.dialogue_finished
	
	# Unlock Player
	if is_instance_valid(player_instance):
		player_instance.set_physics_process(true)

# --- FOX EVENT TRIGGER ---
# Create an Area2D named "FoxEventTrigger" and connect body_entered here
func _on_fox_event_trigger_body_entered(body):
	if body.name == "Player":
		# CHECK: Have we done this already?
		if GameManager.has_triggered_summer_fox_event == false:
			GameManager.has_triggered_summer_fox_event = true
			play_fox_encounter()

func play_fox_encounter():
	# Lock Player
	if is_instance_valid(player_instance):
		player_instance.set_physics_process(false)
		player_instance.velocity = Vector2.ZERO
		if player_instance.has_node("AnimationPlayer"):
			player_instance.get_node("AnimationPlayer").play("Idle")

	# 1. Sound Effect
	if fox_grass_sfx:
		fox_grass_sfx.play()
		await get_tree().create_timer(1.0).timeout 
	else:
		await get_tree().create_timer(0.5).timeout

	# 2. Player Reaction
	var reaction_lines: Array[String] = [
		"What was that?",
		"...."
	]
	DialogueManager.start_dialogue(reaction_lines)
	await DialogueManager.dialogue_finished

	# Unlock Player
	if is_instance_valid(player_instance):
		player_instance.set_physics_process(true)
	
	# Optional: Remove the trigger so it's gone for good
	if has_node("FoxEventTrigger"):
		get_node("FoxEventTrigger").queue_free()

# --- SUMMER OUTRO (EXIT LEVEL) ---
# Connect your Level Exit Area2D to this function
func _on_level_exit_body_entered(body):
	if body.name == "Player":
		finish_summer_level()

func finish_summer_level():
	if is_instance_valid(player_instance):
		player_instance.set_physics_process(false)
		player_instance.velocity = Vector2.ZERO

	# Manual Fade to Black (UI Overlay)
	var overlay = ColorRect.new()
	overlay.color = Color.BLACK
	overlay.modulate.a = 0
	overlay.size = get_viewport_rect().size
	var canvas = CanvasLayer.new()
	canvas.layer = 100 
	add_child(canvas)
	canvas.add_child(overlay)

	var tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 2.0)
	await tween.finished
	
	# Text on Black Screen
	var outro_lines: Array[String] = [
		"You chase the glow, but it always stays just out of reach.",
		"Maybe it’s not meant to be caught, maybe it’s meant to guide.",
		"Summer is the season of forgetting pain. But the sunlight casts shadows.",
		"Do you remember what happened, before you fell?"
	]
	
	DialogueManager.start_dialogue(outro_lines)
	await DialogueManager.dialogue_finished
	
	# Transition to Autumn
	TransitionScreen.transition_to_scene("res://Scenes/Areas/Autumn.tscn", 3.0)

# --- TIMERS & HELPERS (Same as before) ---
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

func update_hearts_ui(current_health: int):
	if is_instance_valid(heart3):
		heart3.texture = FULL_HEART if current_health >= 3 else EMPTY_HEART
	if is_instance_valid(heart2):
		heart2.texture = FULL_HEART if current_health >= 2 else EMPTY_HEART
	if is_instance_valid(heart1):
		heart1.texture = FULL_HEART if current_health >= 1 else EMPTY_HEART

func spawn_player():
	var player_scene = load(GameManager.selected_character_path)
	player_instance = player_scene.instantiate()
	if player_instance.has_signal("health_changed"):
		player_instance.health_changed.connect(update_hearts_ui)
	if player_instance.has_signal("player_died"):
		player_instance.player_died.connect(game_ui.show_game_over)
	player_instance.position = spawn_point.position
	player_instance.name = "Player"
	player_instance.game_ui = game_ui
	add_child(player_instance)
