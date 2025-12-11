extends Node

# --- NODES ---
@onready var player_start_pos = $"../PlayerStartPos"
@onready var camera = $"../EndingCamera"

# --- FOX REFERENCES ---
# 1. The Fox (Root Node)
@onready var fox = $"../Layer 14/FoxActor"

# 2. The Sprite Reference
@onready var fox_sprite = fox

# 3. The Sound
@onready var fox_sound = $"../Layer 14/FoxActor/FoxSound"

# --- SNOW REFERENCE ---
@export var snow_particles : Node2D 

# --- UI NODES ---
@onready var ending_ui = $"../EndingUI"
@onready var choice_container = $"../EndingUI/ChoiceContainer"
@onready var credits_container = $"../EndingUI/CreditsContainer"

# --- BUTTONS ---
@onready var btn_a = $"../EndingUI/ChoiceContainer/VBoxContainer/ButtonA"
@onready var btn_b = $"../EndingUI/ChoiceContainer/VBoxContainer/ButtonB"
@onready var btn_c = $"../EndingUI/ChoiceContainer/VBoxContainer/ButtonC"

@export var walk_distance : float = 600.0
var player

func _ready():
    GameManager.current_season = "Winter"
    choice_container.visible = false
    credits_container.visible = false
    
    btn_a.text = "Promise me you will believe the world when it says it loves you."
    btn_b.text = "Promise me you will not let your fire be mistaken for rage."
    btn_c.text = "Promise me you'll always be your own warmth, and never let this fire go out."
    
    btn_a.pressed.connect(_on_choice_picked)
    btn_b.pressed.connect(_on_choice_picked)
    btn_c.pressed.connect(_on_choice_picked)
    
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
    # --- FIX: FLIP FOX TO FACE LEFT IMMEDIATELY ---
    if fox_sprite:
        fox_sprite.flip_h = true 
    
    # 1. FADE IN / ATMOSPHERE
    await get_tree().create_timer(1.0).timeout
    
    var intro_lines: Array[String] = [
        "The forest is blanketed in snow. Everything is still.",
        "Every sound has gone to sleep beneath the snow.. Silence reigns.",
		"The fox silently waits at the heart of the forest, a single blue flame burning softly against the cold."
    ]
    
    DialogueManager.start_dialogue(intro_lines)
    await DialogueManager.dialogue_finished

    # 2. START WALKING
    if player.has_node("AnimationPlayer"):
        player.animation_player.play("Walk")
        await get_tree().create_timer(0.05).timeout
        player.animation_player.play("Walk")
    
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(player, "position:x", player.position.x + walk_distance, 5.0)
    tween.tween_property(camera, "position:x", camera.position.x + walk_distance, 5.0)
    
    # 3. MID-WALK: SLOW DOWN EFFECT
    await get_tree().create_timer(2.0).timeout
    
    var slow_lines: Array[String] = ["As you move forward, the world around you slows down."]
    DialogueManager.start_dialogue(slow_lines)
    
    # Slow down snow
    if snow_particles:
        var snow_tween = create_tween()
        snow_tween.tween_property(snow_particles, "speed_scale", 0.1, 3.0)
    
    await tween.finished
    
    if player.has_node("AnimationPlayer"):
        player.animation_player.play("Idle")
    
    # 4. SIT TOGETHER IN SILENCE
    var close_tween = create_tween()
    close_tween.tween_property(player, "position:x", player.position.x + 50, 1.0)
    if player.has_node("AnimationPlayer"): player.animation_player.play("Walk")
    await close_tween.finished
    if player.has_node("AnimationPlayer"): player.animation_player.play("Idle")
    
    await get_tree().create_timer(2.0).timeout
    
    var peace_lines: Array[String] = ["For a moment, you sit together in peace, no words, just warmth."]
    DialogueManager.start_dialogue(peace_lines)
    await DialogueManager.dialogue_finished

    # --- FOX PREPARES TO SPEAK ---
    if fox_sprite:
        fox_sprite.play("Wake")
        await fox_sprite.animation_finished
        
        await get_tree().create_timer(1.0).timeout
        
        fox_sprite.play("Idle")
    
    # 5. THE GREAT MONOLOGUE (Fox Mode)
    var monologue_part_1: Array[String] = [
        "You have followed me through the seasons, through rain and light and falling leaves.",
        "You have remembered joy, pain, and warmth. You followed the warmth even when it vanished.",
        "And the forest watched you. It whispered in the language of wind and roots: 'You have always been here.'",
		"You faced the shadows that rose from the mist, not to conquer them, but to understand why they followed you."
    ]
    DialogueManager.start_fox_dialogue(monologue_part_1)
    await DialogueManager.dialogue_finished
    
    var monologue_part_2: Array[String] = [
        "You were the first bloom of spring, and the last leaf that dared to fall.",
        "You were the laughter between raindrops, and the silence beneath the snow.",
        "The blue fire was never a stranger. It was your own heart, calling you home.",
		"Every strike you made was not against the world, but against the part of you that had forgotten its light."
    ]
    DialogueManager.start_fox_dialogue(monologue_part_2)
    await DialogueManager.dialogue_finished
    
    var monologue_part_3: Array[String] = [
        "Every step you took was you remembering. Every shadow you faced was a part of you asking to be seen.",
        "You did not chase the light, you became it. The forest was not a place. It was you...",
		"The blue flame was never a stranger. It was the piece of you that refused to go out."
    ]
    DialogueManager.start_fox_dialogue(monologue_part_3)
    await DialogueManager.dialogue_finished
    
    var monologue_part_4: Array[String] = [
        "..And the forest said: You were never lost. You were only growing.",
        "And the flame said: I have always loved you for staying.",
        "And the world said: I have always loved you for trying.",
        "You are not waking from the forest. The forest is waking within you.",
		"When you open your eyes again, the world will still be waiting, and it will still love you for returning."
    ]
    DialogueManager.start_fox_dialogue(monologue_part_4)
    await DialogueManager.dialogue_finished
    
    # 6. THE PROMISE REQUEST
    await get_tree().create_timer(1.0).timeout
    
    var request_lines: Array[String] = [
        "....",
        "You have done so well to reach me... to Remember.",
        "The world is waiting with love, but can you promise me something before I go..?",
		"Promise me."
    ]
    DialogueManager.start_fox_dialogue(request_lines)
    await DialogueManager.dialogue_finished
    
    # 7. SHOW CHOICES
    choice_container.visible = true

func _on_choice_picked():
    choice_container.visible = false
    
    # 8. THANK YOU
    var thank_you: Array[String] = [
        "Thank you..",
        "Rest now, little light.",
		"The seasons will turn again, and when the next soul wakes beneath these trees, they will walk among your warmth, and call it sunrise..."
    ]
    DialogueManager.start_fox_dialogue(thank_you)
    await DialogueManager.dialogue_finished
    
    await get_tree().create_timer(1.5).timeout
    
    # 9. THE REVEAL
    var reveal_lines: Array[String] = [
        "....",
        "By now you've realized... right?",
        "You know who I am.", 
		"I am you."
    ]
    DialogueManager.start_fox_dialogue(reveal_lines)
    await DialogueManager.dialogue_finished
    
    finish_ending()

func finish_ending():
    # --- ACT 10: FOX LEAVES / FADE OUT ---
    if fox_sprite:
        # FLIP BACK TO RUN RIGHT
        fox_sprite.flip_h = false 
        fox_sprite.play("Run") 
        
    if fox_sound: fox_sound.play()
    
    var run_tween = create_tween()
    run_tween.tween_property(fox, "position:x", fox.position.x + 1000, 3.0)
    var sound_fade = create_tween()
    sound_fade.tween_property(fox_sound, "volume_db", -80.0, 3.0)
    
    var cam_tween = create_tween()
    cam_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    cam_tween.tween_property(camera, "position:y", camera.position.y - 1080, 8.0)
    await cam_tween.finished
    
    roll_credits()

func roll_credits():
    credits_container.visible = true
    credits_container.position.y = camera.position.y - 800
    var credit_tween = create_tween()
    credit_tween.tween_property(credits_container, "position:y", camera.position.y + 2000, 35.0)
    await credit_tween.finished
    
    TransitionScreen.transition_to_scene("res://Scenes/Areas/main_menu.tscn", 5.0)
