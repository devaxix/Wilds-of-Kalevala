extends Node

# --- NODES ---
@onready var player_start_pos = $"../PlayerStartPos"
@onready var fox = $"../FoxActor"
@onready var fox_sprite = $"../FoxActor" 
@onready var camera = $"../EndingCamera"

# --- NEW: FOX AUDIO ---
@onready var fox_sound = $"../FoxActor/FoxSound"

# --- UI NODES ---
@onready var ending_ui = $"../EndingUI"
@onready var choice_container = $"../EndingUI/ChoiceContainer"
@onready var credits_container = $"../EndingUI/CreditsContainer"

# --- SETTINGS ---
@export var walk_distance : float = 600.0 
var player

# --- FOX TEXT BOX ---
@export var fox_textbox_texture : Texture2D

func _ready():
	GameManager.current_season = "Winter"
	choice_container.visible = false
	credits_container.visible = false
	
	# Connect buttons
	$"../EndingUI/ChoiceContainer/VBoxContainer/ButtonA".pressed.connect(_on_choice_picked)
	$"../EndingUI/ChoiceContainer/VBoxContainer/ButtonB".pressed.connect(_on_choice_picked)
	$"../EndingUI/ChoiceContainer/VBoxContainer/ButtonC".pressed.connect(_on_choice_picked)
	
	spawn_player_character()
	start_cutscene()

func spawn_player_character():
	var player_scene = load(GameManager.selected_character_path)
	player = player_scene.instantiate()
	get_parent().call_deferred("add_child", player)
	
	await get_tree().process_frame
	
	player.position = player_start_pos.position + Vector2(0, -50)
	
	player.is_cutscene = false
	player.velocity = Vector2.ZERO 
	
	for i in range(100):
		await get_tree().physics_frame
		player.velocity.x = 0
		if player.is_on_floor():
			break 
	
	player.is_cutscene = true
	player.velocity = Vector2.ZERO
	
	if player.has_node("AnimationTree"):
		player.get_node("AnimationTree").active = false

func start_cutscene():
	await get_tree().create_timer(1.0).timeout
	
	# --- ACT 1: PLAYER WALKS ---
	if player.has_node("AnimationPlayer"):
		player.animation_player.play("Walk")
		await get_tree().create_timer(0.05).timeout
		player.animation_player.play("Walk")
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(player, "position:x", player.position.x + walk_distance, 4.0)
	tween.tween_property(camera, "position:x", camera.position.x + walk_distance, 4.0)
	
	await tween.finished
	
	if player.has_node("AnimationPlayer"):
		player.animation_player.play("Idle")
	
	# --- ACT 2: FOX WAKES ---
	fox_sprite.flip_h = true 
	
	await get_tree().create_timer(0.5).timeout
	fox_sprite.play("Wake")
	await fox_sprite.animation_finished
	
	# --- ACT 3: FOX APPROACHES ---
	fox_sprite.play("Run") 
	
	if fox_sound: fox_sound.play()
	
	var fox_tween = create_tween()
	fox_tween.tween_property(fox, "position:x", fox.position.x - 150, 1.5)
	
	await fox_tween.finished
	
	if fox_sound: fox_sound.stop()
	
	fox_sprite.play("Idle")
	
	# --- ACT 4: DIALOGUE 1 ---
	DialogueManager.set_custom_theme(fox_textbox_texture, 1.5)
	
	var lines: Array[String] = [
		"You have done so well to reach me... to Remember.",
		"The world is waiting with love..."
	]
	
	# UPDATED: Use the new function so it knows these are SCREEN PIXELS
	DialogueManager.start_screen_dialogue(Vector2(960, 1020), lines)
	
	await DialogueManager.dialogue_finished
	
	DialogueManager.reset_theme()
	choice_container.visible = true

func _on_choice_picked():
	choice_container.visible = false
	await get_tree().create_timer(1.0).timeout
	
	# --- ACT 5: DIALOGUE 2 ---
	DialogueManager.set_custom_theme(fox_textbox_texture, 1.5)
	
	var lines: Array[String] = [
		"Thank you...", 
		"...", 
		"By now you've realized... right?", 
		"You know who I am.", 
		"I am you."
	]
	
	# UPDATED: Use Screen Dialogue here too
	DialogueManager.start_screen_dialogue(Vector2(960, 1020), lines)
	
	await DialogueManager.dialogue_finished
	
	DialogueManager.reset_theme()
	finish_ending()

func finish_ending():
	# --- ACT 6: FOX LEAVES ---
	fox_sprite.flip_h = false 
	fox_sprite.play("Run") 
	
	if fox_sound: fox_sound.play()
	
	var run_tween = create_tween()
	run_tween.tween_property(fox, "position:x", fox.position.x + 1000, 3.0)
	
	var sound_fade = create_tween()
	sound_fade.tween_property(fox_sound, "volume_db", -80.0, 3.0)
	
	# --- ACT 7: CAMERA PANS UP ---
	var cam_tween = create_tween()
	cam_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	cam_tween.tween_property(camera, "position:y", camera.position.y - 1080, 8.0)
	
	await cam_tween.finished
	
	# --- ACT 8: CREDITS ---
	roll_credits()

func roll_credits():
	credits_container.visible = true
	credits_container.position.y = camera.position.y - 800
	
	var credit_tween = create_tween()
	credit_tween.tween_property(credits_container, "position:y", camera.position.y + 2000, 25.0)
	
	await credit_tween.finished
	TransitionScreen.transition_to_scene("res://Scenes/Areas/main_menu.tscn")
