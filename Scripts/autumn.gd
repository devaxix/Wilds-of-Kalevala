extends Node2D

# --- CAMERA LIMITS ---
@export var camera_limit_right: int = 10000 
@export var camera_limit_bottom: int = 1080 
@export var camera_limit_top: int = 0
@export var camera_limit_left: int = -830

var level_season: String = "Autumn"

@onready var spawn_point = $PlayerSpawnPoint
@onready var game_ui = $GameUI
var player_instance : CharacterBody2D 

# --- FOX REFERENCES ---
# IMPORTANT: In your Scene Tree, rename the Fox node to "FoxActor"
@onready var fox = $Fox
# Since the root is the sprite, we use the same node for both
@onready var fox_sprite = fox 
@onready var fox_sound = $Fox/FoxSound

# --- AMBIANCE ---
@onready var wind_ambiance = $WindAmbiance if has_node("WindAmbiance") else null
@onready var crow_ambiance = $CrowAmbiance if has_node("CrowAmbiance") else null

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

	if is_instance_valid(wind_ambiance): wind_ambiance.play()
	if is_instance_valid(crow_ambiance): crow_ambiance.play()
	
	update_hearts_ui(3)
	spawn_player()
	
	# Setup Fox (Idle & Face Left)
	if fox_sprite:
		fox_sprite.flip_h = true
		fox_sprite.play("Idle")

	# --- 1. PLAY INTRO ON SPAWN (If not seen yet) ---
	if GameManager.has_seen_autumn_intro == false:
		GameManager.has_seen_autumn_intro = true
		start_autumn_intro()

# --- PART 1: INTRO (Plays when level starts) ---
func start_autumn_intro():
	await get_tree().process_frame
	if is_instance_valid(player_instance):
		player_instance.set_physics_process(false)
		player_instance.velocity = Vector2.ZERO
		if player_instance.has_node("AnimationPlayer"):
			player_instance.get_node("AnimationPlayer").play("Idle")

	# Atmospheric Text (Fixed Syntax Errors)
	var intro_lines: Array[String] = [
		"The world is quieter now. Even the trees seem tired.",
		"Leaves fall like embers. The forest is changing, or maybe it’s showing you what it always was.",
		"The fox’s trail is harder to follow, sometimes it flickers, as if fading. The air carries a deep, golden melancholy.",
		"You find places you remember now.. the broken branch laying across the path, the tree carved with initials, the quiet stream where water runs slow.",
		"Parts of your Memory return in full color, and with it, pain...",
		"You remember faces. The sound of someone calling your name. The warmth that once surrounded you.",
		"You remember losing it."
	]
	
	DialogueManager.start_dialogue(intro_lines)
	await DialogueManager.dialogue_finished
	
	# Unlock Player
	if is_instance_valid(player_instance):
		player_instance.set_physics_process(true)

# --- PART 2: THE FOX MEETING (Plays when Trigger is hit) ---
func _on_cutscene_trigger_body_entered(body):
	if body.name == "Player":
		if GameManager.has_seen_autumn_cutscene == false:
			GameManager.has_seen_autumn_cutscene = true
			start_fox_meeting()

func start_fox_meeting():
	# 1. Lock Player
	if is_instance_valid(player_instance):
		player_instance.set_physics_process(false)
		player_instance.velocity = Vector2.ZERO
		if player_instance.has_node("AnimationPlayer"):
			player_instance.get_node("AnimationPlayer").play("Idle")

	# 2. Player Realization Text
	var player_lines: Array[String] = ["I remember what happened... the accident, the loneliness, the distance from who I was."]
	DialogueManager.start_dialogue(player_lines)
	await DialogueManager.dialogue_finished

	# 3. Fox Speaks
	if fox_sprite:
		fox_sprite.flip_h = true 
		fox_sprite.play("Idle")
	
	var fox_lines: Array[String] = [
		"To remember is to hurt, but to forget is to disappear...",
		"The blue fire flickers weaker now, but it doesn’t vanish. Even as everything else falls away… the light still tries to reach you...",
		"I still try to reach you..",
		"Pain is not the end.. It’s the proof that you’re still alive enough to feel.",
		"Don’t stop walking.. The forest hasn’t finished speaking."
	]
	
	DialogueManager.start_fox_dialogue(fox_lines)
	await DialogueManager.dialogue_finished
	
	# 4. Fox Leaves
	if fox_sprite:
		fox_sprite.flip_h = false # Face Right
		fox_sprite.play("Run")
	
	if fox_sound: fox_sound.play()
	
	# Move Fox off screen
	var tween = create_tween()
	tween.tween_property(fox, "position:x", fox.position.x + 800, 3.0)
	
	await tween.finished
	if fox_sound: fox_sound.stop()
	
	# Hide Fox (So you can't touch him)
	if fox: fox.visible = false
	
	# 5. Unlock Player
	if is_instance_valid(player_instance):
		player_instance.set_physics_process(true)
	
	if has_node("CutsceneTrigger"):
		get_node("CutsceneTrigger").queue_free()

# --- LEVEL EXIT ---
func _on_level_exit_body_entered(body):
	if body.name == "Player":
		# 5.0 Seconds Transition for drama
		TransitionScreen.transition_to_scene("res://Scenes/Areas/EndingCutscene.tscn", 5.0)

# --- HELPERS ---
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
