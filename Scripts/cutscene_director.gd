extends Node

# --- NODES ---
@onready var player_start_pos = $"../PlayerStartPos"
@onready var fox = $"../FoxActor"
@onready var fox_sprite = $"../FoxActor" # Since root is AnimatedSprite2D
@onready var camera = $"../EndingCamera"

# --- UI NODES ---
@onready var ending_ui = $"../EndingUI"
@onready var choice_container = $"../EndingUI/ChoiceContainer"
@onready var credits_container = $"../EndingUI/CreditsContainer"

# --- SETTINGS ---
@export var walk_distance : float = 600.0 # Make sure this is big enough to reach the Fox!
var player 

func _ready():
	# 1. HIDE UI INITIALLY
	choice_container.visible = false
	credits_container.visible = false
	
	# Connect buttons
	$"../EndingUI/ChoiceContainer/ButtonA".pressed.connect(_on_choice_picked)
	$"../EndingUI/ChoiceContainer/ButtonB".pressed.connect(_on_choice_picked)
	$"../EndingUI/ChoiceContainer/ButtonC".pressed.connect(_on_choice_picked)
	
	spawn_player_character()
	start_cutscene()

func spawn_player_character():
	var player_scene = load(GameManager.selected_character_path)
	player = player_scene.instantiate()
	get_parent().call_deferred("add_child", player)
	
	# Wait for the node to enter the tree
	await get_tree().process_frame
	
	# 1. SPAWN HIGH: Put them 50 pixels ABOVE the marker
	# This ensures they are not stuck inside the floor
	player.position = player_start_pos.position + Vector2(0, -50)
	
	# 2. ENABLE PHYSICS (Briefly)
	# We turn OFF cutscene mode so gravity works
	player.is_cutscene = false 
	player.velocity = Vector2.ZERO # Ensure they fall straight down
	
	# 3. AUTOMATED LANDING
	# We wait frame-by-frame until the feet touch the ground
	# (We add a safety limit of 100 frames so it doesn't freeze forever if no floor exists)
	for i in range(100):
		await get_tree().physics_frame
		
		# Force X velocity to 0 every frame so they don't slide while falling
		player.velocity.x = 0 
		
		if player.is_on_floor():
			break # They touched the ground! Stop waiting.
	
	# 4. LOCK IT
	# Now that they are on the floor, we freeze them.
	player.is_cutscene = true 
	player.velocity = Vector2.ZERO
	
	# 5. KILL ANIMATION TREE (If present)
	if player.has_node("AnimationTree"):
		player.get_node("AnimationTree").active = false

func start_cutscene():
	# Wait for fade-in
	await get_tree().create_timer(1.0).timeout
	
	# --- ACT 1: PLAYER WALKS & CAMERA FOLLOWS ---
	
	# Force the animation to play
	if player.has_node("AnimationPlayer"): 
		player.animation_player.play("Walk")
		# Force it again a split second later just to be safe!
		await get_tree().create_timer(0.05).timeout
		player.animation_player.play("Walk")
	# 1. Start Animation
	if player.has_node("AnimationPlayer"): 
		player.animation_player.play("Walk")
	
	# 2. Move Player
	var tween = create_tween()
	tween.set_parallel(true) # Run the next two tweens AT THE SAME TIME
	
	# Move Player Right
	tween.tween_property(player, "position:x", player.position.x + walk_distance, 4.0)
	
	# Move Camera Right (So we see the Fox!)
	tween.tween_property(camera, "position:x", camera.position.x + walk_distance, 4.0)
	
	await tween.finished
	
	# Stop Animation
	if player.has_node("AnimationPlayer"):
		player.animation_player.play("Idle")
	
	# --- ACT 2: FOX WAKES ---
	# Setup Fox direction
	fox_sprite.flip_h = true # Look LEFT at player
	
	await get_tree().create_timer(0.5).timeout
	fox_sprite.play("Wake") 
	await fox_sprite.animation_finished
	
	# --- ACT 3: FOX APPROACHES ---
	fox_sprite.play("Run") 
	var fox_tween = create_tween()
	# Walk slightly Left towards player
	fox_tween.tween_property(fox, "position:x", fox.position.x - 150, 1.5)
	await fox_tween.finished
	fox_sprite.play("Idle") 
	
	# --- ACT 4: DIALOGUE 1 ---
	var lines: Array[String] = [
		"You have done so well to reach me... to Remember.",
		"The world is waiting with love, but can you promise me something before I go...?"
	]
	DialogueManager.start_dialogue(fox.global_position, lines)
	
	# FIX: Wait for the signal! (Make sure your DialogueManager emits this)
	await DialogueManager.dialogue_finished
	
	# Show choices ONLY after text is gone
	choice_container.visible = true

func _on_choice_picked():
	choice_container.visible = false
	
	# Delay for dramatic effect
	await get_tree().create_timer(1.0).timeout
	
	# --- ACT 5: DIALOGUE 2 ---
	var lines: Array[String] = [
		"Thank you...", 
		"...", 
		"By now you've realized... right?", 
		"You know who I am.", 
		"I am you."
	]
	DialogueManager.start_dialogue(fox.global_position, lines)
	
	# FIX: Wait for signal again
	await DialogueManager.dialogue_finished
	
	finish_ending()

func finish_ending():
	# --- ACT 6: FOX LEAVES ---
	fox_sprite.flip_h = false # Turn RIGHT
	fox_sprite.play("Run") 
	
	var run_tween = create_tween()
	run_tween.tween_property(fox, "position:x", fox.position.x + 1000, 3.0)
	
	# --- ACT 7: CAMERA PANS UP (MOON SHOT) ---
	var cam_tween = create_tween()
	cam_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Move Camera UP by 1080 pixels
	# Because Parallax Moon Scale is 0, Moon stays on screen.
	# Because Parallax Ground Scale is 1, Ground moves down.
	cam_tween.tween_property(camera, "position:y", camera.position.y - 1080, 8.0)
	
	await cam_tween.finished
	
	# --- ACT 8: CREDITS ---
	roll_credits()

func roll_credits():
	credits_container.visible = true
	
	# Start ABOVE the camera
	credits_container.position.y = camera.position.y - 800 
	
	var credit_tween = create_tween()
	
	# Move DOWN much further
	# Changed from +1200 to +2000 to ensure it goes WAY off screen
	credit_tween.tween_property(credits_container, "position:y", camera.position.y + 2000, 25.0)
	
	await credit_tween.finished
	
	# FADE OUT
	TransitionScreen.transition_to_scene("res://Scenes/Areas/main_menu.tscn")
